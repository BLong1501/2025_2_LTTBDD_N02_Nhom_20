// lib/view/food/add_food_screen.dart

import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/food_model.dart';
import '../../services/food_service.dart';
import '../../services/meal_plan_service.dart';

class AddFoodScreen extends StatefulWidget {
  final String planId;

  const AddFoodScreen({super.key, required this.planId});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  // Controllers
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _noteController = TextEditingController();
  final _tagsController = TextEditingController();
  
  // --- MỚI: Thêm controller cho Thời gian
  final _timeController = TextEditingController();

  // Variables
  bool _isLoading = false;
  bool _isShared = true;
  String _selectedCategory = 'Món chính';
  
  // --- MỚI: Variables cho Khẩu phần và Độ khó
  double _servings = 2.0; // Số người mặc định (2 người)
  String _selectedDifficulty = 'Dễ';
  final List<String> _difficulties = ['Dễ', 'Trung bình', 'Khó'];
  
  // Quản lý ảnh
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];

  final List<String> _categories = [
    'Món chính', 'Ăn sáng', 'Ăn vặt', 'Tráng miệng', 'Healthy', 'Đồ uống'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    _noteController.dispose();
    _tagsController.dispose();
    _timeController.dispose(); // Đừng quên dispose
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        limit: 10 - _selectedImages.length,
        imageQuality: 70,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedFiles.map((x) => File(x.path)));
          if (_selectedImages.length > 10) {
             _selectedImages = _selectedImages.sublist(0, 10);
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text("Chỉ được chọn tối đa 10 ảnh!")),
             );
          }
        });
      }
    } catch (e) {
      debugPrint("Lỗi chọn ảnh: $e");
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<List<String>> _uploadImages(String userId) async {
    List<String> imageUrls = [];
    final storageRef = FirebaseStorage.instance.ref();

    for (var imageFile in _selectedImages) {
      try {
        String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
        Reference ref = storageRef.child("foods/$userId/$fileName");
        UploadTask uploadTask = ref.putFile(imageFile);
        TaskSnapshot snapshot = await uploadTask;

        if (snapshot.state == TaskState.success) {
          String downloadUrl = await ref.getDownloadURL();
          imageUrls.add(downloadUrl);
        } else {
          print("Upload thất bại cho file: $fileName");
        }
      } catch (e) {
        print("Lỗi chi tiết khi up ảnh: $e");
      }
    }
    return imageUrls;
  }

  void _saveFood() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập tên món ăn")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      List<String> uploadedImageUrls = [];
      if (_selectedImages.isNotEmpty) {
        uploadedImageUrls = await _uploadImages(user.uid);
      }
      
      String mainImageUrl = uploadedImageUrls.isNotEmpty ? uploadedImageUrls.first : ''; 
      
      List<String> ingredientsList = _ingredientsController.text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      List<String> tagsList = _tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      final newFood = FoodModel(
        id: '', 
        authorId: user.uid,
        title: _titleController.text.trim(),
        imageUrl: mainImageUrl,
        ingredients: ingredientsList,
        instructions: _instructionsController.text.trim(),
        note: _noteController.text.trim(),
        isShared: _isShared,
        likedBy: [],
        createdAt: DateTime.now(),
        tags: tagsList,
        category: _selectedCategory,
        isApproved: true,
        // --- TRUYỀN DỮ LIỆU MỚI VÀO MODEL ---
        time: _timeController.text.trim().isNotEmpty ? _timeController.text.trim() : "15 phút", // Mặc định nếu trống
        servings: "${_servings.toInt()} người", 
        difficulty: _selectedDifficulty,
      );

      // Lưu vào kho chung
      await FoodService().addFood(newFood); 

      // Nếu đang trong Plan thì lưu thêm vào Plan
      if (widget.planId.isNotEmpty) {
        await FoodService().addFoodToPlan(widget.planId, newFood);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lưu thành công!")));
        Navigator.pop(context);
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
        title: const Text("Thêm món mới"),
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
            // 1. TÊN MÓN
            _buildSectionTitle("Thông tin cơ bản"),
            _buildTextField(
              controller: _titleController,
              label: "Tên món ăn",
              hint: "VD: Phở bò tái nạm",
              icon: Icons.restaurant,
            ),
            
            const SizedBox(height: 15),
            
            // 2. CHỌN ẢNH
            const Text("Hình ảnh (Tối đa 10 ảnh)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  if (index == _selectedImages.length) {
                     if (_selectedImages.length >= 10) return const SizedBox.shrink();
                     return InkWell(
                       onTap: _pickImages,
                       child: Container(
                         width: 100,
                         decoration: BoxDecoration(
                           color: Colors.grey[100],
                           borderRadius: BorderRadius.circular(10),
                           border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                         ),
                         child: const Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Icon(Icons.add_a_photo, color: Colors.grey),
                             SizedBox(height: 4),
                             Text("Thêm ảnh", style: TextStyle(color: Colors.grey, fontSize: 12)),
                           ],
                         ),
                       ),
                     );
                  }
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_selectedImages[index], width: 120, height: 120, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 4, right: 4,
                        child: InkWell(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            // --- 3. KHU VỰC THÔNG SỐ (THỜI GIAN, KHẨU PHẦN, ĐỘ KHÓ) ---
            _buildSectionTitle("Chi tiết món ăn"),
            
            // Hàng 1: Thời gian và Độ khó
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _timeController,
                    label: "Thời gian làm",
                    hint: "VD: 15 phút, 1 giờ",
                    icon: Icons.timer,
                  ),
                ),
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
                    items: _difficulties.map((String diff) {
                      return DropdownMenuItem<String>(value: diff, child: Text(diff));
                    }).toList(),
                    onChanged: (newValue) => setState(() => _selectedDifficulty = newValue!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Hàng 2: Slider chọn khẩu phần (Số người)
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.group, color: Colors.orange),
                      const SizedBox(width: 10),
                      Text(
                        "Khẩu phần: ${_servings.toInt()} người", 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                      ),
                    ],
                  ),
                  Slider(
                    value: _servings,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    activeColor: Colors.deepOrange,
                    inactiveColor: Colors.orange.shade100,
                    label: _servings.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _servings = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 4. DANH MỤC & TAGS
            _buildSectionTitle("Phân loại"),
             Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: "Danh mục",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    ),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(value: category, child: Text(category));
                    }).toList(),
                    onChanged: (newValue) => setState(() => _selectedCategory = newValue!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _tagsController,
              label: "Thẻ (Tags)",
              hint: "Ngan cach bang dau phay (VD: cay, nhanh, de lam)",
              icon: Icons.local_offer,
            ),

            const SizedBox(height: 25),

            // 5. NGUYÊN LIỆU & CÁCH LÀM
            _buildSectionTitle("Công thức"),
            _buildTextField(
              controller: _ingredientsController,
              label: "Nguyên liệu",
              hint: "Mỗi dòng một nguyên liệu...",
              icon: Icons.list,
              maxLines: 4,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _instructionsController,
              label: "Cách làm chi tiết",
              hint: "Bước 1: ...",
              icon: Icons.description,
              maxLines: 6,
            ),

            const SizedBox(height: 25),

            // 6. KHÁC
            _buildSectionTitle("other".tr()),
            _buildTextField(
              controller: _noteController,
              label: "personal_note".tr(),
              icon: Icons.note,
            ),
             SizedBox(height: 10),
            SwitchListTile(
              title:  Text("share".tr()),
              value: _isShared,
              activeColor: Colors.deepOrange,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) => setState(() => _isShared = val),
            ),

            const SizedBox(height: 30),

            // NÚT LƯU
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveFood,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    :  Text(
                        "save".tr(),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, color: Colors.orange) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.deepOrange, width: 2)),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }
}