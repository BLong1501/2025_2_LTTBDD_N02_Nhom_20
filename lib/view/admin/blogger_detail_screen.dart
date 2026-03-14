import 'package:btl_ltdd/view/admin/admin_food_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Thêm import Firestore để thực hiện lệnh xóa
import 'package:easy_localization/easy_localization.dart';
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

  // --- HÀM XỬ LÝ XÓA TÀI KHOẢN ---
  void _confirmDeleteUser(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("delete".tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        // Tạm dùng câu hỏi xác nhận chung từ từ điển
        content: Text("Bạn có chắc chắn muốn xóa tài khoản '${user.username}' không? Hành động này sẽ xóa dữ liệu người dùng khỏi hệ thống."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("cancel".tr(), style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx); // Đóng hộp thoại
              try {
                // Xóa document của user này trong bảng 'users'
                await FirebaseFirestore.instance.collection('users').doc(user.id).delete();
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Đã xóa tài khoản thành công!")),
                  );
                  Navigator.pop(context); // Quay về màn hình danh sách user
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Lỗi khi xóa: $e")),
                  );
                }
              }
            },
            child: Text("delete".tr(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminUserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "blogger_detail".tr(),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        // --- THÊM NÚT XÓA Ở GÓC PHẢI APPBAR ---
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
            tooltip: 'Xóa tài khoản',
            onPressed: () => _confirmDeleteUser(context),
          ),
        ],
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
                    Text("${"phone_number".tr()}: ${user.phoneNumber}"),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat(
                          "post".tr(),
                          stats['totalFoods'].toString(),
                        ),
                        _buildStat(
                          "follower".tr(),
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
                      return Center(
                        child: Text("nothing".tr()),
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
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[200], // Nền xám lót dưới
                                child: (food.imageUrl.isNotEmpty &&
                                        food.imageUrl.startsWith('http'))
                                    ? Image.network(
                                        food.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image, color: Colors.grey),
                                      )
                                    : const Icon(
                                        Icons.fastfood,
                                        color: Colors.deepPurple,
                                      ),
                              ),
                            ),
                            title: Text(food.title),
                            subtitle: Text(
                              food.isApproved ? "approved".tr() : "Chờ duyệt",
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