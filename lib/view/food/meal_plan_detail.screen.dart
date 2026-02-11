import 'package:flutter/material.dart';
import '../../models/meal_plan_model.dart';
import '../../models/food_model.dart';
import '../../services/food_service.dart';
import 'add_food_screen.dart';

class MealPlanDetailScreen extends StatelessWidget {
  final MealPlanModel plan; // Nhận dữ liệu Plan từ màn hình trước

  const MealPlanDetailScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(plan.name), // Hiển thị tên Plan trên tiêu đề
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Phần Header: Ghi chú của Plan
          if (plan.note.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.orange[50],
              child: Text("📝 Ghi chú: ${plan.note}", style: const TextStyle(fontStyle: FontStyle.italic)),
            ),

          // Phần Danh sách món ăn
          Expanded(
            child: StreamBuilder<List<FoodModel>>(
              stream: FoodService().getFoodsInPlan(plan.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.soup_kitchen, size: 60, color: Colors.grey),
                        const SizedBox(height: 10),
                        const Text("Chưa có món ăn nào trong thực đơn này."),
                        TextButton(
                          onPressed: () {
                             Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddFoodScreen(planId: plan.id),
                                ),
                              );
                          }, 
                          child: const Text("Thêm món ngay")
                        )
                      ],
                    ),
                  );
                }

                final foods = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: foods.length,
                  itemBuilder: (context, index) {
                    final food = foods[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: food.imageUrl.isNotEmpty
                            ? Image.network(food.imageUrl, width: 50, height: 50, fit: BoxFit.cover, 
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood))
                            : const Icon(Icons.fastfood, size: 40, color: Colors.orange),
                        title: Text(food.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${food.ingredients.length} nguyên liệu"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () {
                             // Xóa món ăn
                             FoodService().deleteFood(plan.id, food.id);
                          },
                        ),
                        onTap: () {
                          // Sau này có thể làm màn hình xem chi tiết công thức (RecipeDetailScreen)
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddFoodScreen(planId: plan.id),
            ),
          );
        },
        label: const Text("Thêm món", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.orange,
      ),
    );
  }
}