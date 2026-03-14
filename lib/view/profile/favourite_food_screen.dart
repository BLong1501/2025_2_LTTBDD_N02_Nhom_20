import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart'; // Nếu bạn dùng đa ngôn ngữ
import '../../models/food_model.dart';
import '../food/meal_plan_detail_screen.dart';

class FavoriteFoodsScreen extends StatelessWidget {
  const FavoriteFoodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title:  Text("favorite_foods".tr())),
        body: const Center(child: Text("Vui lòng đăng nhập để xem.")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:  Text("favorite_foods".tr(), style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Câu lệnh "Thần thánh": Tìm tất cả món ăn mà mảng likedBy có chứa ID của mình
        stream: FirebaseFirestore.instance
            .collection('foods')
            .where('likedBy', arrayContains: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 15),
                  Text("nothing".tr(), style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                ],
              ),
            );
          }

          final favDocs = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 15,
              mainAxisSpacing: 20,
            ),
            itemCount: favDocs.length,
            itemBuilder: (context, index) {
              final docData = favDocs[index].data() as Map<String, dynamic>;
              final food = FoodModel.fromMap(docData, favDocs[index].id);
              double averageRating = (docData['rating'] ?? 0.0).toDouble();

              return InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MealDetailScreen(food: food))),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, spreadRadius: 2)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: food.imageUrl.isNotEmpty 
                                  ? Image.network(food.imageUrl, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Center(child: Icon(Icons.broken_image, color: Colors.grey))) 
                                  : const Center(child: Icon(Icons.fastfood, color: Colors.orange, size: 40)),
                              ),
                            ),
                            // Thêm trái tim đỏ nhỏ ở góc báo hiệu đã thích
                            Positioned(
                              top: 10, right: 10,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: const Icon(Icons.favorite, color: Colors.red, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${food.time} • ⭐ ${averageRating > 0 ? averageRating.toStringAsFixed(1) : "0/5"}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(food.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}