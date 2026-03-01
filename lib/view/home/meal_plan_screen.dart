import 'package:btl_ltdd/view/food/meal_plan_detail_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../models/food_model.dart';
import '../../services/food_service.dart';
import '../food/add_food_screen.dart';
// import '../food/meal_detail_screen.dart'; // Giữ nguyên import này

class MealPlansScreen extends StatefulWidget {
  const MealPlansScreen({super.key});

  @override
  State<MealPlansScreen> createState() => _MealPlansScreenState();
}

class _MealPlansScreenState extends State<MealPlansScreen> {
  
  // Chuyển sang trang thêm món (Giữ nguyên logic cũ của bạn)
  void _goToAddFoodScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddFoodScreen(planId: ''), 
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Nền xám nhạt
      body: StreamBuilder<List<FoodModel>>(
        // Giữ nguyên logic lấy Món ăn từ FoodService
        stream: FoodService().getAllUserFoods(), 
        builder: (context, snapshot) {
          final foods = snapshot.data ?? [];
          final foodCount = foods.length;

          return Column(
            children: [
              // 1. Header Cam & Nút Tạo (Thiết kế mới giống ảnh)
              _buildHeaderWithButton(),

              // 2. Tiêu đề phụ (Hiển thị số lượng món ăn)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                child: Row(
                  children: [
                    Text(
                      "${"recipe_list".tr()} (${foods.length})", // Sửa tiêu đề cho phù hợp context món ăn
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Danh sách món ăn (Card trắng)
              Expanded(
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : foods.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: foods.length,
                            itemBuilder: (context, index) {
                              final food = foods[index];
                              return _buildFoodItem(food); // Giữ nguyên widget hiển thị món ăn
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget Header cam + Nút nổi (Cập nhật UI giống ảnh mẫu)
  Widget _buildHeaderWithButton() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Nền cam
        Container(
          padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 50),
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF6F00), Color(0xFFFF3D00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child:  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.soup_kitchen, color: Colors.white, size: 28),
                  SizedBox(width: 10),
                  Text("Cooky", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 5),
              Text("your_meal_plans".tr(), style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),

        // Nút "Thêm món mới" nổi lên
        Positioned(
          bottom: -25,
          left: 20,
          right: 20,
          child: InkWell(
            onTap: _goToAddFoodScreen, // Gọi hàm cũ của bạn
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(color: Colors.orange.shade100, width: 1),
              ),
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.deepOrange),
                  SizedBox(width: 8),
                  Text(
                    "add_recipe".tr(), // Đổi text cho phù hợp logic thêm món
                    style: TextStyle(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget hiển thị từng món ăn (Giữ nguyên logic hiển thị của bạn, chỉ chỉnh lại style Card cho đẹp hơn chút)
  Widget _buildFoodItem(FoodModel food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MealDetailScreen(food: food), // Giữ nguyên chuyển trang
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(15.0), // Tăng padding lên chút
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: food.imageUrl.isNotEmpty
                    ? Image.network(
                        food.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80, height: 80, color: Colors.orange[100],
                          child: const Icon(Icons.broken_image, color: Colors.orange),
                        ),
                      )
                    : Container(width: 80, height: 80, color: Colors.orange[100], child: const Icon(Icons.fastfood, color: Colors.orange)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${food.ingredients.length} nguyên liệu",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // Widget hiển thị khi trống
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Icon(Icons.fastfood_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 10),
          const Text("Chưa có món ăn nào", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}