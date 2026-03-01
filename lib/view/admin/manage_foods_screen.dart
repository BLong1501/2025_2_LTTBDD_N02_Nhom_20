import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_food_provider.dart'; // Đảm bảo đúng đường dẫn
import '../../models/food_model.dart';           // Đảm bảo đúng đường dẫn
import 'add_edit_food_screen.dart';              // Đảm bảo đúng đường dẫn

class ManageFoodsScreen extends StatelessWidget {
  const ManageFoodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. SỬA LỖI THIẾU PROVIDER: Phải khai báo provider ở đây để dùng cho các nút bấm bên dưới
    final provider = Provider.of<AdminFoodProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        title: const Text("Kiểm duyệt công thức"),
        backgroundColor: const Color(0xff6A5AE0),
        foregroundColor: Colors.white, // Chữ trắng cho nổi trên nền tím
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("foods").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final foods = snapshot.data!.docs;

          if (foods.isEmpty) {
            return const Center(child: Text("Chưa có công thức nào."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: foods.length,
            itemBuilder: (context, index) {
              final doc = foods[index];
              // 2. SỬA LỖI CONVERT DATA: Phải ép kiểu dữ liệu Firebase thành FoodModel
              final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              final FoodModel food = FoodModel.fromMap(data, doc.id);

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  // 3. ĐÃ BỔ SUNG errorBuilder BẢO VỆ CHỐNG VĂNG APP DO LỖI ẢNH
                  leading: food.imageUrl.isNotEmpty
                      ? Image.network(
                          food.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          color: Colors.orange[100],
                          child: const Icon(Icons.fastfood, color: Colors.deepOrange),
                        ),
                  title: Text(food.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                      "Author: ${food.authorId}\n"
                      "Status: ${food.isApproved ? "Đã duyệt" : "Bị ẩn"}"),
                  isThreeLine: true, // Để text \n không bị cắt xén
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == "delete") {
                        provider.deleteFood(food);
                      }
                      if (value == "approve") {
                        provider.toggleApproval(food);
                      }
                      if (value == "edit") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditFoodScreen(food: food),
                          ),
                        );
                      }
                      if (value == "feature") {
                        provider.toggleFeatured(food);
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: "approve",
                        child: Text(
                          food.isApproved ? "Ẩn bài" : "Duyệt bài",
                        ),
                      ),
                      const PopupMenuItem(
                        value: "edit",
                        child: Text("Sửa"),
                      ),
                      const PopupMenuItem(
                        value: "delete",
                        child: Text("Xóa bài", style: TextStyle(color: Colors.red)),
                      ),
                      const PopupMenuItem(
                        value: "feature",
                        child: Text("Hiển thị Discover"),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff6A5AE0),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditFoodScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}