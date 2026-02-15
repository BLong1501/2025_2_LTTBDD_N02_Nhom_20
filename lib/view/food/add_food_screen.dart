import 'package:btl_ltdd/services/meal_plan_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/food_model.dart';
import '../../services/food_service.dart';

class AddFoodScreen extends StatefulWidget {
  final String planId; // ID của Plan mà món ăn này sẽ thuộc về

  const AddFoodScreen({super.key, required this.planId});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  // Controllers
  final _titleController = TextEditingController();
  final _imageController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _noteController = TextEditingController();
  final _tagsController = TextEditingController(); // Nhập tags ngăn cách bằng dấu phẩy

  // Variables
  bool _isLoading = false;
  bool _isShared = true; // Mặc định là chia sẻ
  String _selectedCategory = 'Món chính'; // Danh mục mặc định

  // Danh sách danh mục mẫu
  final List<String> _categories = [
    'Món chính', 'Ăn sáng', 'Ăn vặt', 'Tráng miệng', 'Healthy', 'Đồ uống'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _imageController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    _noteController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  // Hàm Lưu Món Ăn
 void _saveFood() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập tên món ăn")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      
      // Xử lý dữ liệu đầu vào
      List<String> ingredientsList = _ingredientsController.text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      List<String> tagsList = _tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      final newFood = FoodModel(
        id: '', 
        authorId: user?.uid ?? 'unknown',
        title: _titleController.text.trim(),
        imageUrl: _imageController.text.trim(),
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

      // --- SỬA ĐOẠN NÀY ---
      if (widget.planId.isEmpty) {
        // TRƯỜNG HỢP 1: Chưa có Plan -> Gọi service tạo Plan kèm Food
        await MealPlanService().createPlanWithFirstFood(newFood);
      } else {
        // TRƯỜNG HỢP 2: Đã có Plan -> Chỉ thêm Food vào Plan cũ
        await FoodService().addFoodToPlan(widget.planId, newFood);
      }
      // --------------------

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
            // 1. TÊN MÓN & ẢNH
            _buildSectionTitle("Thông tin cơ bản"),
            _buildTextField(
              controller: _titleController,
              label: "Tên món ăn",
              hint: "VD: Phở bò tái nạm",
              icon: Icons.restaurant,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _imageController,
              label: "Link hình ảnh (URL)",
              hint: "https://example.com/image.jpg",
              icon: Icons.image,
            ),
            
            const SizedBox(height: 25),

            // 2. DANH MỤC & TAGS
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

            // 3. NGUYÊN LIỆU & CÁCH LÀM
            _buildSectionTitle("Công thức"),
            _buildTextField(
              controller: _ingredientsController,
              label: "Nguyên liệu",
              hint: "Mỗi dòng một nguyên liệu:\n- 500g thịt bò\n- 1 củ hành tây",
              icon: Icons.list,
              maxLines: 4,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _instructionsController,
              label: "Cách làm chi tiết",
              hint: "Bước 1: Rửa sạch thịt...\nBước 2: Luộc sơ...",
              icon: Icons.description,
              maxLines: 6,
            ),

            const SizedBox(height: 25),

            // 4. KHÁC
            _buildSectionTitle("Tùy chọn khác"),
            _buildTextField(
              controller: _noteController,
              label: "Ghi chú cá nhân",
              hint: "Lưu ý khi nấu...",
              icon: Icons.note,
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text("Chia sẻ công khai?"),
              subtitle: const Text("Cho phép mọi người nhìn thấy món này"),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
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

  // Widget hỗ trợ vẽ Tiêu đề mục
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  // Widget hỗ trợ vẽ TextField đẹp
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
        ),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }
}