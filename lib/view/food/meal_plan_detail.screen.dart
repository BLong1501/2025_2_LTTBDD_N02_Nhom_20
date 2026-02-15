import 'package:flutter/material.dart';
import '../../models/food_model.dart';

class MealDetailScreen extends StatelessWidget {
  final FoodModel food;

  const MealDetailScreen({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 1. Ảnh món ăn (Header co giãn)
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            backgroundColor: Colors.deepOrange,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                food.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                ),
              ),
              background: food.imageUrl.isNotEmpty
                  ? Image.network(
                      food.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: Colors.grey),
                    )
                  : Container(color: Colors.orange[200]),
            ),
          ),

          // 2. Nội dung chi tiết
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Danh mục
                  Chip(
                    label: Text(food.category.isNotEmpty ? food.category : "Món ngon"),
                    backgroundColor: Colors.orange[50],
                    labelStyle: const TextStyle(color: Colors.deepOrange),
                  ),
                  const SizedBox(height: 20),

                  // Nguyên liệu
                  const Text("🛒 Nguyên liệu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ...food.ingredients.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text("• $e", style: const TextStyle(fontSize: 16)),
                      )),

                  const SizedBox(height: 20),

                  // Cách làm
                  const Text("🍳 Cách làm", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    food.instructions.isNotEmpty ? food.instructions : "Chưa có hướng dẫn cụ thể.",
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}