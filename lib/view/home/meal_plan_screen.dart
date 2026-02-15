import 'package:btl_ltdd/view/food/meal_plan_detail.screen.dart';
import 'package:flutter/material.dart';
import '../../models/food_model.dart';
import '../../services/food_service.dart';
import '../food/add_food_screen.dart';
// import '../food/meal_detail_screen.dart'; // <--- QUAN TRỌNG: BỎ COMMENT DÒNG NÀY

class MealPlansScreen extends StatefulWidget {
  const MealPlansScreen({super.key});

  @override
  State<MealPlansScreen> createState() => _MealPlansScreenState();
}

class _MealPlansScreenState extends State<MealPlansScreen> {
  
  // Chuyển sang trang thêm món
  void _goToAddFoodScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        // planId rỗng ('') nghĩa là thêm vào danh sách chung, không thuộc Plan cụ thể nào
        builder: (_) => const AddFoodScreen(planId: ''), 
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildCustomHeader(),

          Expanded(
            child: StreamBuilder<List<FoodModel>>(
              // Gọi hàm lấy tất cả món ăn chung (cần đảm bảo FoodService có hàm này)
              stream: FoodService().getAllUserFoods(), 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final foods = snapshot.data ?? [];

                if (foods.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fastfood, size: 50, color: Colors.grey[400]),
                        const SizedBox(height: 10),
                        const Text("Chưa có món ăn nào.", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: foods.length,
                  itemBuilder: (context, index) {
                    final food = foods[index];
                    return _buildFoodItem(food);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
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
          child: const Column(
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
              Text("Danh sách món ăn của tôi", style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
        Positioned(
          bottom: -25,
          left: 20,
          right: 20,
          child: InkWell(
            onTap: _goToAddFoodScreen,
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.deepOrange),
                  SizedBox(width: 8),
                  Text("Thêm món mới", style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFoodItem(FoodModel food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          
          // --- SỰ KIỆN CLICK: CHUYỂN SANG MÀN HÌNH CHI TIẾT ---
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MealDetailScreen(food: food), // Truyền data món ăn sang
              ),
            );
          },
          // ----------------------------------------------------

          child: Padding(
            padding: const EdgeInsets.all(12),
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
                      Text(food.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 5),
                      Text("${food.ingredients.length} nguyên liệu", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}