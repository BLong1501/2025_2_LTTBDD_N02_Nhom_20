import 'package:btl_ltdd/view/admin/add_edit_food_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/food_model.dart';
// Màn hình thêm mới
import 'admin_add_recipe_screen.dart'; 
// IMPORT MÀN HÌNH EDIT VÀO ĐÂY (AddEditFoodScreen)
// import 'package:btl_ltdd/view/food/add_edit_food_screen.dart'; // Sửa lại đường dẫn nếu cần

class ManageFoodsScreen extends StatelessWidget {
  const ManageFoodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text("admin_manage_recipes".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('foods')
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
                  title: Text(
                    food.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
                              child: Text("approved".tr(), style: TextStyle(color: Colors.green[800], fontSize: 11)),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(4)),
                              child: Text("level".tr(), style: TextStyle(color: Colors.orange[800], fontSize: 11)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  
                  // ==========================================
                  // ĐÂY LÀ CHỖ CÓ NÚT SỬA VÀ XÓA (GỘP LẠI)
                  // ==========================================
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min, 
                    children: [
                      // NÚT SỬA (Màu xanh, hình cây bút)
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // Điều hướng sang trang AddEditFoodScreen và quăng dữ liệu Food sang đó
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AddEditFoodScreen(food: food)),
                          );
                        },
                      ),
                      // NÚT XÓA (Màu đỏ, hình thùng rác)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          _confirmDelete(context, food.id);
                        },
                      ),
                    ],
                  ),
                  // ==========================================
                ),
              );
            },
          );
        },
      ),

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
        label: Text("add_recipe".tr()),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String foodId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("delete_recipe".tr()),
        content:  Text("delete".tr() + " '${foodId}'?"), // Bạn có thể thay foodId bằng tên món ăn nếu muốn
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("cancel".tr(), style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              FirebaseFirestore.instance.collection('foods').doc(foodId).delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xóa món ăn!")));
            },
            child: Text("delete".tr(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}