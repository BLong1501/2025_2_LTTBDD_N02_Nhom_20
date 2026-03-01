import 'package:btl_ltdd/view/food/edit_food_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import để lấy UID hiện tại
import '../../models/food_model.dart';
// import '../../services/food_service.dart'; // Import để gọi hàm xóa (nếu có)

class MealDetailScreen extends StatelessWidget {
  final FoodModel food;

  const MealDetailScreen({super.key, required this.food});

  // Hàm hiển thị hộp thoại xác nhận xóa
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận xóa",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            "Bạn có chắc chắn muốn xóa công thức này không? Hành động này không thể hoàn tác."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Đóng hộp thoại
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx); // Đóng hộp thoại trước

              try {
                // Gọi hàm xóa từ FoodService (Cần đảm bảo bạn đã tạo hàm deleteFood trong FoodService)
                // await FoodService().deleteFood(food.id);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Đã xóa bài đăng thành công!")));
                  Navigator.pop(context); // Trở về màn hình trước đó
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("Lỗi: $e")));
                }
              }
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double imageHeight = MediaQuery.of(context).size.height * 0.4;

    // Kiểm tra xem User hiện tại có phải là Tác giả của bài đăng này không
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final bool isAuthor = currentUserId == food.authorId;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. PHẦN HEADER ẢNH & TIÊU ĐỀ
            Stack(
              children: [
                // A. Ảnh nền
                Container(
                  height: imageHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    image: food.imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(food.imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: food.imageUrl.isEmpty
                      ? const Center(
                          child: Icon(Icons.fastfood,
                              size: 50, color: Colors.orange))
                      : null,
                ),

                // B. Lớp Gradient đen mờ
                Container(
                  height: imageHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black
                            .withOpacity(0.3), // Tối nhẹ ở trên để nổi nút
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),

                // C. Nút Back (Góc trái trên)
                Positioned(
                  top: 50,
                  left: 20,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.black, size: 24),
                    ),
                  ),
                ),

                // --- MỚI: Nút Tùy chọn (Sửa/Xóa) cho Tác giả ---
                if (isAuthor)
                  Positioned(
                    top: 50,
                    right: 20,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.black),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        onSelected: (value) async {
                          if (value == 'edit') {
                            // Chuyển sang màn hình Edit và nhận dữ liệu trả về nếu thành công
                            final updatedFood = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => EditFoodScreen(food: food)),
                            );

                            // Nếu muốn màn hình MealDetail cập nhật lại ngay lập tức,
                            // bạn cần dùng Stateful Widget cho MealDetailScreen.
                            // Tạm thời nó sẽ pop lại khi lưu thành công và bạn vào lại sẽ thấy data mới!
                          } else if (value == 'delete') {
                            _confirmDelete(context);
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.blue, size: 20),
                                SizedBox(width: 10),
                                Text("Chỉnh sửa"),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red, size: 20),
                                SizedBox(width: 10),
                                Text("Xóa bài đăng",
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // D. Tiêu đề & Tag
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          food.category.isNotEmpty ? food.category : "Món ngon",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        food.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 2. PHẦN NỘI DUNG TRẮNG (GIỮ NGUYÊN)
            Container(
              transform: Matrix4.translationValues(0, -20, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem(
                            Icons.access_time_filled,
                            food.time.isNotEmpty ? food.time : "15 phút",
                            "Thời gian",
                            Colors.orange.shade100,
                            Colors.deepOrange),
                        _buildStatItem(
                            Icons.people,
                            food.servings.isNotEmpty
                                ? food.servings
                                : "2 người",
                            "Khẩu phần",
                            Colors.blue.shade50,
                            Colors.blue),
                        _buildStatItem(
                            Icons.local_fire_department,
                            food.difficulty.isNotEmpty ? food.difficulty : "Dễ",
                            "Độ khó",
                            Colors.purple.shade50,
                            Colors.purple),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text("Nguyên liệu",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(height: 15),
                    ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: food.ingredients.length,
                      separatorBuilder: (ctx, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildIngredientItem(food.ingredients[index]);
                      },
                    ),
                    const SizedBox(height: 30),
                    const Text("Hướng dẫn",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(height: 15),
                    _buildInstructionList(food.instructions),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Các Widget con _buildStatItem, _buildIngredientItem, _buildInstructionList giữ nguyên như cũ
  Widget _buildStatItem(IconData icon, String value, String label,
      Color bgColor, Color iconColor) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildIngredientItem(String ingredient) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.deepOrange),
          const SizedBox(width: 15),
          Expanded(
              child: Text(ingredient,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87))),
          const Icon(Icons.check_circle_outline, color: Colors.grey, size: 18),
        ],
      ),
    );
  }

  Widget _buildInstructionList(String instructions) {
    List<String> steps =
        instructions.split('\n').where((s) => s.trim().isNotEmpty).toList();
    if (steps.isEmpty)
      return const Text("Chưa có hướng dẫn cụ thể.",
          style: TextStyle(color: Colors.grey));

    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      separatorBuilder: (ctx, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                  color: Colors.deepOrange, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text("${index + 1}",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 15),
            Expanded(
                child: Text(steps[index].trim(),
                    style: const TextStyle(
                        fontSize: 16, height: 1.5, color: Colors.black87))),
          ],
        );
      },
    );
  }
}
