import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/food_model.dart';
import '../../services/food_service.dart';

class EditFoodScreen extends StatefulWidget {
  final FoodModel food; // Nhận dữ liệu món ăn cũ cần sửa

  const EditFoodScreen({super.key, required this.food});

  @override
  State<EditFoodScreen> createState() => _EditFoodScreenState();
}

class _EditFoodScreenState extends State<EditFoodScreen> {
  // Controllers
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _noteController = TextEditingController();
  final _tagsController = TextEditingController();
  final _timeController = TextEditingController();

  // Variables
  bool _isLoading = false;
  bool _isShared = true;
  String _selectedCategory = 'Món chính';
  double _servings = 2.0;
  String _selectedDifficulty = 'Dễ';
  
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = []; // Chứa ảnh mới (nếu người dùng chọn lại)

  final List<String> _categories = ['Món chính', 'Ăn sáng', 'Ăn vặt', 'Tráng miệng', 'Healthy', 'Đồ uống'];
  final List<String> _difficulties = ['Dễ', 'Trung bình', 'Khó'];

  @override
  void initState() {
    super.initState();
    // ĐỔ DỮ LIỆU CŨ VÀO CÁC Ô NHẬP LIỆU
    _titleController.text = widget.food.title;
    _ingredientsController.text = widget.food.ingredients.join('\n');
    _instructionsController.text = widget.food.instructions;
    _noteController.text = widget.food.note;
    _tagsController.text = widget.food.tags.join(', ');
    _timeController.text = widget.food.time;
    
    _isShared = widget.food.isShared;
    
    if (_categories.contains(widget.food.category)) {
      _selectedCategory = widget.food.category;
    }
    if (_difficulties.contains(widget.food.difficulty)) {
      _selectedDifficulty = widget.food.difficulty;
    }
    
    // Tách lấy số từ chuỗi "2 người"
    String servingNumber = widget.food.servings.replaceAll(RegExp(r'[^0-9]'), '');
    if (servingNumber.isNotEmpty) {
      _servings = double.tryParse(servingNumber) ?? 2.0;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    _noteController.dispose();
    _tagsController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(limit: 1, imageQuality: 70);
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages = [File(pickedFiles.first.path)]; // Tạm thời hỗ trợ đổi 1 ảnh
        });
      }
    } catch (e) {
      debugPrint("Lỗi chọn ảnh: $e");
    }
  }

  Future<String> _uploadNewImage(String userId) async {
    if (_selectedImages.isEmpty) return widget.food.imageUrl; // Nếu không chọn ảnh mới, giữ nguyên ảnh cũ

    final storageRef = FirebaseStorage.instance.ref();
    String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
    Reference ref = storageRef.child("foods/$userId/$fileName");
    
    UploadTask uploadTask = ref.putFile(_selectedImages.first);
    TaskSnapshot snapshot = await uploadTask;
    return await ref.getDownloadURL();
  }

  void _updateFood() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập tên món ăn")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // 1. Xử lý ảnh (Giữ ảnh cũ hoặc up ảnh mới)
      String finalImageUrl = await _uploadNewImage(user.uid);
      
      // 2. Xử lý text
      List<String> ingredientsList = _ingredientsController.text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      List<String> tagsList = _tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      // 3. Cập nhật Model sử dụng copyWith
      final updatedFood = widget.food.copyWith(
        title: _titleController.text.trim(),
        imageUrl: finalImageUrl,
        ingredients: ingredientsList,
        instructions: _instructionsController.text.trim(),
        note: _noteController.text.trim(),
        isShared: _isShared,
        tags: tagsList,
        category: _selectedCategory,
        time: _timeController.text.trim().isNotEmpty ? _timeController.text.trim() : "15 phút",
        servings: "${_servings.toInt()} người", 
        difficulty: _selectedDifficulty,
      );

      // 4. Gửi lên Firebase
      await FoodService().updateFood(updatedFood); 

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cập nhật thành công!")));
        Navigator.pop(context, updatedFood); // Quay lại và truyền data mới về
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Chỉnh sửa món ăn"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Thông tin cơ bản"),
            _buildTextField(controller: _titleController, label: "Tên món ăn", icon: Icons.restaurant),
            
            const SizedBox(height: 15),
            
            // --- Hiển thị ảnh cũ hoặc ảnh mới ---
            const Text("Hình ảnh", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),
            InkWell(
              onTap: _pickImages,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _selectedImages.isNotEmpty
                  ? Image.file(_selectedImages.first, width: double.infinity, height: 200, fit: BoxFit.cover)
                  : widget.food.imageUrl.isNotEmpty 
                      ? Image.network(widget.food.imageUrl, width: double.infinity, height: 200, fit: BoxFit.cover)
                      : Container(
                          width: double.infinity, height: 150, color: Colors.grey[200],
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Icon(Icons.add_a_photo, color: Colors.grey), Text("Đổi ảnh", style: TextStyle(color: Colors.grey))],
                          ),
                        ),
              ),
            ),

            const SizedBox(height: 25),

            _buildSectionTitle("Chi tiết món ăn"),
            Row(
              children: [
                Expanded(child: _buildTextField(controller: _timeController, label: "Thời gian", icon: Icons.timer)),
                const SizedBox(width: 15),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDifficulty,
                    decoration: InputDecoration(
                      labelText: "Độ khó",
                      prefixIcon: const Icon(Icons.local_fire_department, color: Colors.orange),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    ),
                    items: _difficulties.map((String diff) => DropdownMenuItem(value: diff, child: Text(diff))).toList(),
                    onChanged: (val) => setState(() => _selectedDifficulty = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Khẩu phần: ${_servings.toInt()} người", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Slider(
                    value: _servings, min: 1, max: 10, divisions: 9, activeColor: Colors.deepOrange,
                    onChanged: (val) => setState(() => _servings = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            _buildSectionTitle("Phân loại"),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(labelText: "Danh mục", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              items: _categories.map((String cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 15),
            _buildTextField(controller: _tagsController, label: "Thẻ (Tags)", hint: "Cách nhau bằng dấu phẩy", icon: Icons.local_offer),

            const SizedBox(height: 25),
            _buildSectionTitle("Công thức"),
            _buildTextField(controller: _ingredientsController, label: "Nguyên liệu", maxLines: 4),
            const SizedBox(height: 15),
            _buildTextField(controller: _instructionsController, label: "Cách làm chi tiết", maxLines: 6),

            const SizedBox(height: 25),
            _buildSectionTitle("Tùy chọn khác"),
            _buildTextField(controller: _noteController, label: "Ghi chú cá nhân"),
            SwitchListTile(
              title: const Text("Chia sẻ công khai?"), value: _isShared, activeColor: Colors.deepOrange,
              onChanged: (val) => setState(() => _isShared = val),
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateFood,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("CẬP NHẬT", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)));
  }

  Widget _buildTextField({required TextEditingController controller, required String label, String? hint, IconData? icon, int maxLines = 1}) {
    return TextField(
      controller: controller, maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label, hintText: hint,
        prefixIcon: icon != null ? Icon(icon, color: Colors.orange) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}