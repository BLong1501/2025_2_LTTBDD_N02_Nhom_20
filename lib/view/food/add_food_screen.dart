import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/food_model.dart';
import '../../services/food_service.dart';

class AddFoodScreen extends StatefulWidget {
  final String planId; // Cần biết đang thêm vào Plan nào

  const AddFoodScreen({super.key, required this.planId});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController(); // Nhập ngăn cách bởi dấu phẩy
  final _instructionsController = TextEditingController();
  final _imageController = TextEditingController();
  
  bool _isLoading = false;

  void _saveFood() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập tên món")));
      return;
    }

    setState(() => _isLoading = true);

    // 1. Chuyển chuỗi nguyên liệu thành List (ngăn cách bởi dấu xuống dòng)
    List<String> ingredientsList = _ingredientsController.text
        .split('\n')
        .where((element) => element.trim().isNotEmpty)
        .toList();

    // 2. Tạo đối tượng FoodModel
    final user = FirebaseAuth.instance.currentUser;
    final newFood = FoodModel(
      id: '', // Firestore tự tạo
      authorId: user?.uid ?? '',
      title: _titleController.text.trim(),
      imageUrl: _imageController.text.trim(), // Tạm thời nhập link ảnh, sau này nâng cấp upload ảnh sau
      ingredients: ingredientsList,
      instructions: _instructionsController.text.trim(),
      createdAt: DateTime.now(),
      isShared: false,
    );

    // 3. Gọi Service lưu
    await FoodService().addFoodToPlan(widget.planId, newFood);

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context); // Đóng màn hình thêm
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thêm món mới")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Tên món ăn (VD: Phở Bò)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _imageController,
              decoration: const InputDecoration(labelText: "Link ảnh (URL)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _ingredientsController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Nguyên liệu (Mỗi dòng 1 cái)", 
                hintText: "Thịt bò\nBánh phở\nHành tây...",
                border: OutlineInputBorder()
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _instructionsController,
              maxLines: 6,
              decoration: const InputDecoration(labelText: "Cách làm chi tiết", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveFood,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("LƯU MÓN ĂN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}