import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/food_model.dart';
// Nhớ đổi đường dẫn này cho đúng với vị trí file AdminAddRecipeScreen của bạn
import 'admin_add_recipe_screen.dart'; 

class ManageFoodsScreen extends StatelessWidget {
  const ManageFoodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // Màu nền xám nhạt cho app Admin
      appBar: AppBar(
        title: const Text("Quản lý công thức Admin", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple, // Màu tím đặc trưng cho Admin
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      
      // STREAM LẤY DỮ LIỆU CÁC MÓN ĂN DO ADMIN ĐĂNG
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('foods')
            // Lọc những bài được đánh dấu là nổi bật (bài của Admin)
            .where('isFeatured', isEqualTo: true) 
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 15),
                  Text("Bạn chưa thêm công thức nào.", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                ],
              ),
            );
          }

          final foods = snapshot.data!.docs;

          // HIỂN THỊ DẠNG LISTVIEW (Danh sách dọc)
          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: foods.length,
            itemBuilder: (context, index) {
              final data = foods[index].data() as Map<String, dynamic>;
              final food = FoodModel.fromMap(data, foods[index].id);

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  // Ảnh món ăn
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[200],
                      child: food.imageUrl.isNotEmpty
                          ? Image.network(
                              food.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
                            )
                          : const Icon(Icons.fastfood, color: Colors.deepPurple),
                    ),
                  ),
                  // Tên món ăn
                  title: Text(
                    food.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Thông tin phụ
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("🕒 ${food.time}  •  👥 ${food.servings}", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(4)),
                              child: Text("Đã duyệt", style: TextStyle(color: Colors.green[800], fontSize: 11)),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(4)),
                              child: Text(food.difficulty, style: TextStyle(color: Colors.orange[800], fontSize: 11)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  // Nút Xóa (Tùy chọn cho Admin)
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      // Chức năng xóa món ăn khỏi Firebase
                      _confirmDelete(context, food.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),

      // NÚT CỘNG (MỞ TRANG THÊM CÔNG THỨC)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminAddRecipeScreen()),
          );
        },
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Thêm món"),
      ),
    );
  }

  // Hàm hiển thị hộp thoại xác nhận xóa
  void _confirmDelete(BuildContext context, String foodId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xóa công thức"),
        content: const Text("Bạn có chắc chắn muốn xóa món ăn này khỏi hệ thống không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // Lệnh xóa Firebase
              FirebaseFirestore.instance.collection('foods').doc(foodId).delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xóa món ăn!")));
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}