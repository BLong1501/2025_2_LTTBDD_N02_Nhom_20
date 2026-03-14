import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/food_model.dart'; 

class AdminAddRecipeScreen extends StatefulWidget {
  const AdminAddRecipeScreen({super.key});

  @override
  State<AdminAddRecipeScreen> createState() => _AdminAddRecipeScreenState();
}

class _AdminAddRecipeScreenState extends State<AdminAddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Các Controllers để lấy dữ liệu từ Text Field
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _timeController = TextEditingController(text: "30 ${'minutes'.tr()}");
  final TextEditingController _servingsController = TextEditingController(text: "2 ${'people'.tr()}");
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  late String _selectedDifficulty;
  File? _imageFile;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Đặt mặc định độ khó (medium) bằng ngôn ngữ hiện tại
    _selectedDifficulty = 'medium'.tr(); 
  }

  // --- Dọn dẹp bộ nhớ khi đóng trang ---
  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    _servingsController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  // --- HÀM CHỌN ẢNH TỪ THƯ VIỆN ---
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // --- HÀM LƯU LÊN FIREBASE ---
  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null) {
      // Thông báo chưa chọn ảnh
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("select_image".tr())));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Upload ảnh lên Firebase Storage
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child('food_images/$fileName.jpg');
      UploadTask uploadTask = storageRef.putFile(_imageFile!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // 2. Lấy ID Admin hiện tại
      String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'admin_id';

      // 3. Xử lý chuỗi nguyên liệu và tags
      List<String> ingredientsList = _ingredientsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
          
      List<String> tagsList = _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      // 4. Tạo Object FoodModel
      FoodModel newRecipe = FoodModel(
        id: '', // Firebase sẽ tự tạo ID
        authorId: currentUserId,
        title: _titleController.text.trim(),
        imageUrl: downloadUrl,
        ingredients: ingredientsList,
        instructions: _instructionsController.text.trim(),
        createdAt: DateTime.now(),
        category: _categoryController.text.trim(),
        tags: tagsList,
        isApproved: true, // Mặc định hiển thị luôn
        isFeatured: true, // Đánh dấu là công thức nổi bật của Admin
        isShared: true,
        time: _timeController.text.trim(),
        servings: _servingsController.text.trim(),
        difficulty: _selectedDifficulty,
        likedBy: [], // Tránh lỗi thả tim
        rating: 0.0, // Tránh lỗi tính sao
        note: '',
      );

      // 5. Đẩy lên Firestore collection 'foods'
      await FirebaseFirestore.instance.collection('foods').add(newRecipe.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("recipe_updated".tr())));
        Navigator.pop(context); // Đóng màn hình
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("add_recipe".tr()),
        backgroundColor: Colors.deepPurple, 
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- KHU VỰC CHỌN ẢNH ---
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                          ),
                          child: _imageFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                                    const SizedBox(height: 10),
                                    Text("select_image".tr(), style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- CÁC TRƯỜNG NHẬP LIỆU ---
                    _buildTextField("food_name".tr(), _titleController, "Eg: Sweet and sour pork ribs", maxLines: 1),
                    
                    Row(
                      children: [
                        Expanded(child: _buildTextField("time".tr(), _timeController, "30 ${'minutes'.tr()}", maxLines: 1)),
                        const SizedBox(width: 15),
                        Expanded(child: _buildTextField("servings".tr(), _servingsController, "2 ${'people'.tr()}", maxLines: 1)),
                      ],
                    ),

                    const SizedBox(height: 15),
                    Text("level".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      value: _selectedDifficulty,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      ),
                      // Dịch các mục trong dropdown
                      items: ['easy'.tr(), 'medium'.tr(), 'hard'.tr()].map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() => _selectedDifficulty = newValue!);
                      },
                    ),

                    const SizedBox(height: 15),
                    _buildTextField("category".tr(), _categoryController, "Eg: ${'main_dish'.tr()}", maxLines: 1),
                    
                    const SizedBox(height: 15),
                    _buildTextField("tag".tr() + " (,)", _tagsController, "Eg: meat, spicy", maxLines: 1), 

                    const SizedBox(height: 15),
                    _buildTextField("ingredients".tr() + " (,)", _ingredientsController, "Eg: 500g ribs, 2 tomatoes...", maxLines: 3),
                    
                    const SizedBox(height: 15),
                    _buildTextField("instructions".tr(), _instructionsController, "Step 1...\nStep 2...", maxLines: 6),

                    const SizedBox(height: 30),

                    // --- NÚT LƯU TRỮ ---
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: _saveRecipe,
                        child: Text("save".tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  // Hàm hỗ trợ vẽ TextField
  Widget _buildTextField(String label, TextEditingController controller, String hint, {required int maxLines}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            // Cảnh báo nếu nhập thiếu
            validator: (value) => value!.trim().isEmpty ? "${'search_for'.tr()} $label" : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.all(15),
            ),
          ),
        ],
      ),
    );
  }
}