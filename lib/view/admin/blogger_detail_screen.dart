import 'package:btl_ltdd/view/admin/admin_food_detail_screen.dart';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/food_model.dart';
import '../../providers/admin_user_provider.dart';
import 'package:provider/provider.dart';

class BloggerDetailScreen extends StatelessWidget {
  final UserModel user;

  const BloggerDetailScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminUserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chi tiết Blogger",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: provider.getBloggerStats(user.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final stats = snapshot.data!;

          return Column(
            children: [
              /// ================= HEADER =================
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(user.email),
                    Text("SĐT: ${user.phoneNumber}"),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat(
                          "Bài đăng",
                          stats['totalFoods'].toString(),
                        ),
                        _buildStat(
                          "Followers",
                          stats['totalFollowers'].toString(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(),

              /// ================= LIST FOOD =================
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: provider.getBloggerFoods(user.id),
                  builder: (context, foodSnapshot) {
                    if (!foodSnapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final foodMaps = foodSnapshot.data!;

                    if (foodMaps.isEmpty) {
                      return const Center(
                        child: Text("Chưa có bài đăng nào"),
                      );
                    }

                    /// Convert Map -> FoodModel
                    final foods = foodMaps.map((map) {
                      return FoodModel.fromMap(
                        map,
                        map['id'] ?? '',
                      );
                    }).toList();

                    return ListView.builder(
                      itemCount: foods.length,
                      itemBuilder: (context, index) {
                        final food = foods[index];

                        return Card(
                          margin: const EdgeInsets.all(12),
                          child: ListTile(
                            // --- ĐÃ SỬA LỖI HÌNH ẢNH Ở ĐÂY ---
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[200], // Nền xám lót dưới
                                child: food.imageUrl.isNotEmpty
                                    ? Image.network(
                                        food.imageUrl,
                                        fit: BoxFit.cover,
                                        // Tấm khiên chống văng app khi link ảnh chết
                                        errorBuilder: (context, error, stackTrace) => const Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.fastfood,
                                        color: Colors.deepPurple,
                                      ),
                              ),
                            ),
                            title: Text(food.title),
                            subtitle: Text(
                              food.isApproved ? "Đã duyệt" : "Chờ duyệt",
                              style: TextStyle(
                                color: food.isApproved ? Colors.green : Colors.orange,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdminFoodDetailScreen(foodId: food.id),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStat(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(title),
      ],
    );
  }
}