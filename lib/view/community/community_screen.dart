import 'package:btl_ltdd/view/food/meal_plan_detail.screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Cần import để lấy info user
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/food_model.dart';
import '../../services/food_service.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final FoodService _service = FoodService();
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Cộng đồng Cooky",
          style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: StreamBuilder<List<FoodModel>>(
        stream: _service.getCommunityFoods(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final foods = snapshot.data ?? [];

          if (foods.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.public_off, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("Chưa có bài đăng nào.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: foods.length,
            separatorBuilder: (ctx, index) => const Divider(height: 30, thickness: 8, color: Color(0xFFF5F5F5)),
            itemBuilder: (context, index) {
              return _buildPostItem(foods[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildPostItem(FoodModel food) {
    final bool isLiked = food.likedBy.contains(_currentUserId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. HEADER: Thay vì code cứng, ta gọi Widget _AuthorInfo để load dữ liệu thật
        _AuthorInfo(authorId: food.authorId, category: food.category),

        // 2. ẢNH MÓN ĂN
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MealDetailScreen(food: food)),
            );
          },
          child: food.imageUrl.isNotEmpty
              ? Image.network(
                  food.imageUrl,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (_,__,___) => Container(height: 300, color: Colors.grey[200], child: const Icon(Icons.broken_image)),
                )
              : Container(height: 200, color: Colors.orange[100], child: const Center(child: Icon(Icons.fastfood, size: 50, color: Colors.orange))),
        ),

        // 3. NÚT TƯƠNG TÁC
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.black87,
                  size: 28,
                ),
                onPressed: () {
                  _service.toggleLike(food.id, food.likedBy);
                },
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline, size: 26),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tính năng bình luận đang phát triển")));
                },
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MealDetailScreen(food: food)),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Text("Xem công thức", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      SizedBox(width: 4),
                      Icon(Icons.bookmark_border, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 4. SỐ LIKE VÀ CAPTION
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (food.likedBy.isNotEmpty)
                Text(
                  "${food.likedBy.length} lượt thích",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 5),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  children: [
                    const TextSpan(text: "Mô tả: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: food.note.isNotEmpty ? food.note : food.title,
                      style: const TextStyle(height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              if (food.tags.isNotEmpty)
                Wrap(
                  spacing: 5,
                  children: food.tags.map((tag) => Text("#$tag", style: TextStyle(color: Colors.blue[700]))).toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- WIDGET RIÊNG ĐỂ LOAD THÔNG TIN NGƯỜI ĐĂNG ---
class _AuthorInfo extends StatelessWidget {
  final String authorId;
  final String category;

  const _AuthorInfo({required this.authorId, required this.category});

  // Hàm lấy thông tin user từ Firestore
  Future<Map<String, dynamic>?> _getUserInfo() async {
    try {
      // Giả sử bạn lưu thông tin user trong collection 'users'
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(authorId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print("Lỗi lấy info user: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getUserInfo(),
      builder: (context, snapshot) {
        // Dữ liệu mặc định nếu đang load hoặc lỗi
        String name = "Người dùng Cooky";
        String? avatarUrl;

        if (snapshot.hasData && snapshot.data != null) {
          final data = snapshot.data!;
          // Thay 'fullName' và 'avatarUrl' bằng đúng tên trường bạn lưu trong Firestore
          name = data['fullName'] ?? data['name'] ?? data['email'] ?? "Người dùng ẩn danh";
          avatarUrl = data['avatarUrl'] ?? data['image']; 
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.orange.shade100,
                backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) 
                    ? NetworkImage(avatarUrl) 
                    : null,
                child: (avatarUrl == null || avatarUrl.isEmpty) 
                    ? const Icon(Icons.person, color: Colors.deepOrange) 
                    : null,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    category.isNotEmpty ? category : "Món ngon",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),
        );
      },
    );
  }
}