import 'package:flutter/material.dart';
import '../../models/meal_plan_model.dart';
import '../../models/food_model.dart';
import '../../services/food_service.dart';
import 'add_food_screen.dart';

class MealPlanDetailScreen extends StatelessWidget {
  final MealPlanModel plan;

  const MealPlanDetailScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Nền xám nhạt
      body: Column(
        children: [
          // 1. HEADER MÀU CAM
          Container(
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF6F00), Color(0xFFFF3D00)], // Cam đậm -> Cam đỏ
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nút back nhỏ
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 10),
                // Tiêu đề
                Row(
                  children: [
                    const Icon(Icons.soup_kitchen, color: Colors.white, size: 28),
                    const SizedBox(width: 10),
                    const Text(
                      "Cooky",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  "Kế hoạch bữa ăn: ${plan.name}",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. NÚT "THÊM MÓN ĂN MỚI" (Dạng thẻ trắng nổi)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddFoodScreen(planId: plan.id)),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.orange.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.deepOrange),
                    SizedBox(width: 8),
                    Text(
                      "Thêm món ăn mới",
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

          const SizedBox(height: 20),

          // 3. TIÊU ĐỀ DANH SÁCH
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "DANH SÁCH MÓN ĂN",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 4. DANH SÁCH CÁC MÓN ĂN (LIST VIEW)
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
                        Icon(Icons.no_food, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        const Text("Chưa có món nào", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                final foods = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: foods.length,
                  itemBuilder: (context, index) {
                    final food = foods[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  food.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                                onPressed: () {
                                  // Xóa món ăn
                                  FoodService().deleteFood(plan.id, food.id);
                                },
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Hiển thị nguyên liệu hoặc cách làm ngắn gọn
                          Text(
                            food.ingredients.isNotEmpty 
                                ? "Nguyên liệu: ${food.ingredients.take(3).join(', ')}..."
                                : "Chưa có nguyên liệu",
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                              const SizedBox(width: 5),
                              Text(
                                "Thêm lúc: ${_formatDate(food.createdAt)}", // Bạn cần hàm format ngày hoặc dùng thư viện intl
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Hàm phụ trợ format ngày tháng đơn giản (nếu chưa dùng intl)
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}