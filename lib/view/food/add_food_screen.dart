import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart'; // Cần thêm package này
import 'package:firebase_storage/firebase_storage.dart'; // Cần thêm package này
import '../../models/food_model.dart';
import '../../services/food_service.dart';
import '../../services/meal_plan_service.dart';

class AddFoodScreen extends StatefulWidget {
  final String planId; // ID của Plan (rỗng nếu là tạo mới Plan)

  const AddFoodScreen({super.key, required this.planId});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  // Controllers
  final _titleController = TextEditingController();
  // _imageController không cần dùng nữa vì ta dùng List<File>
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _noteController = TextEditingController();
  final _tagsController = TextEditingController();

  // Variables
  bool _isLoading = false;
  bool _isShared = true;
  String _selectedCategory = 'Món chính';
  
  // Quản lý ảnh
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = []; // Danh sách ảnh đã chọn từ thiết bị

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
    super.dispose();
  }

  // 1. Hàm chọn ảnh từ thư viện
  Future<void> _pickImages() async {
    try {
      // Cho phép chọn nhiều ảnh
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        limit: 10 - _selectedImages.length, // Giới hạn số lượng còn lại
        imageQuality: 70, // Nén ảnh nhẹ
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedFiles.map((x) => File(x.path)));
          // Cắt bớt nếu vượt quá 10 ảnh
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

  // 2. Hàm xoá ảnh khỏi danh sách đã chọn
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // 3. Hàm upload ảnh lên Firebase Storage
 // Sửa lại hàm này trong file add_food_screen.dart
  Future<List<String>> _uploadImages(String userId) async {
    List<String> imageUrls = [];
    final storageRef = FirebaseStorage.instance.ref();

    for (var imageFile in _selectedImages) {
      try {
        String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
        Reference ref = storageRef.child("foods/$userId/$fileName");
        
        // 1. Tạo task upload
        UploadTask uploadTask = ref.putFile(imageFile);

        // 2. Đợi upload hoàn tất (quan trọng!)
        TaskSnapshot snapshot = await uploadTask;

        // 3. Chỉ khi upload thành công mới lấy link
        if (snapshot.state == TaskState.success) {
          String downloadUrl = await ref.getDownloadURL();
          imageUrls.add(downloadUrl);
        } else {
          print("Upload thất bại cho file: $fileName");
        }
      } catch (e) {
        print("Lỗi chi tiết khi up ảnh: $e");
        // Bỏ qua ảnh lỗi, tiếp tục vòng lặp
      }
    }
    return imageUrls;
  }

  // 4. Hàm Lưu Món Ăn (Main Logic)
  void _saveFood() async {
    // Validate cơ bản
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập tên món ăn")));
      return;
    }
    // (Tuỳ chọn) Bắt buộc phải có ít nhất 1 ảnh
    // if (_selectedImages.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng chọn ít nhất 1 ảnh")));
    //   return;
    // }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // A. Upload ảnh trước
      List<String> uploadedImageUrls = [];
      if (_selectedImages.isNotEmpty) {
        uploadedImageUrls = await _uploadImages(user.uid);
      }
      
      // Lấy ảnh đầu tiên làm ảnh đại diện (imageUrl chính), các ảnh khác có thể lưu vào mảng khác nếu Model hỗ trợ
      // Ở đây ta tạm lấy ảnh đầu tiên làm ảnh chính. Nếu Model FoodModel của bạn chỉ có 1 field `imageUrl` (String), ta chỉ lưu 1 ảnh.
      // Nếu FoodModel hỗ trợ `List<String> images`, bạn hãy sửa Model.
      // Giả sử FoodModel hiện tại chỉ có field `imageUrl` là String:
      String mainImageUrl = uploadedImageUrls.isNotEmpty ? uploadedImageUrls.first : ''; 
      
      // Nếu bạn muốn lưu danh sách ảnh vào description hoặc cần sửa Model để có field `List<String> images`.
      // Tạm thời mình dùng ảnh đầu tiên cho `imageUrl`.

      // B. Xử lý dữ liệu text
      List<String> ingredientsList = _ingredientsController.text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      List<String> tagsList = _tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      // C. Tạo Model
      final newFood = FoodModel(
        id: '', 
        authorId: user.uid,
        title: _titleController.text.trim(),
        imageUrl: mainImageUrl, // Lưu link ảnh đã upload
        ingredients: ingredientsList,
        instructions: _instructionsController.text.trim(),
        note: _noteController.text.trim(),
        isShared: _isShared,
        likedBy: [],
        createdAt: DateTime.now(),
        tags: tagsList,
        category: _selectedCategory,
        isApproved: true,
      );

      // D. Lưu vào Firestore
     if (widget.planId.isEmpty) {
        // --- SỬA LẠI ĐOẠN NÀY ---
        // SAI: await MealPlanService().createPlanWithFirstFood(newFood);
        
        // ĐÚNG: Lưu thẳng vào kho món ăn chung để màn hình chính hiển thị được
        await FoodService().addFood(newFood); 
      } else {
        // Thêm vào Plan cũ (Giữ nguyên)
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
            
            // 2. CHỌN ẢNH (Giao diện mới)
            const Text("Hình ảnh (Tối đa 10 ảnh)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),
            
            // Khu vực hiển thị ảnh
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length + 1, // +1 cho nút thêm
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  // Nút thêm ảnh (Luôn nằm cuối hoặc đầu)
                  if (index == _selectedImages.length) {
                     // Nếu đủ 10 ảnh thì ẩn nút thêm
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
                  
                  // Hiển thị ảnh đã chọn
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _selectedImages[index],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Nút xoá ảnh (X)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
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

            // 3. DANH MỤC & TAGS
            _buildSectionTitle("Phân loại"),
            // ... (Giữ nguyên phần này)
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
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() => _selectedCategory = newValue!);
                    },
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

            // 4. NGUYÊN LIỆU & CÁCH LÀM
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

            // 5. KHÁC
            _buildSectionTitle("Tùy chọn khác"),
            _buildTextField(
              controller: _noteController,
              label: "Ghi chú cá nhân",
              icon: Icons.note,
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text("Chia sẻ công khai?"),
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
                    : const Text(
                        "LƯU MÓN ĂN",
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

  // Widget hỗ trợ vẽ Tiêu đề mục (Giữ nguyên)
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  // Widget hỗ trợ vẽ TextField đẹp (Giữ nguyên)
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