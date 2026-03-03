import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_food_provider.dart';
import '../../models/food_model.dart';

class AdminFoodDetailScreen extends StatelessWidget {
  final String foodId;

  const AdminFoodDetailScreen({
    super.key,
    required this.foodId,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AdminFoodProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chi tiết bài đăng",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<FoodModel?>(
        stream: provider.streamFoodById(foodId),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data == null) {
            return const Center(
              child: Text("Bài đăng đã bị xoá"),
            );
          }

          final food = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                /// IMAGE
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(12),
                  child: Image.network(
                    food.imageUrl,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 16),

                /// TITLE
                Text(
                  food.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                /// META INFO
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text("⏱ ${food.time}"),
                    Text("👥 ${food.servings}"),
                    Text("🔥 ${food.difficulty}"),
                  ],
                ),

                const SizedBox(height: 12),

                /// STATUS CHIPS
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      label: Text(
                        food.isApproved
                            ? "Đã duyệt"
                            : "Chờ duyệt",
                        style: const TextStyle(
                            color: Colors.white),
                      ),
                      backgroundColor:
                          food.isApproved
                              ? Colors.green
                              : Colors.orange,
                    ),
                    Chip(
                      label: Text(
                        food.isShared
                            ? "Công khai"
                            : "Riêng tư",
                        style: const TextStyle(
                            color: Colors.white),
                      ),
                      backgroundColor:
                          food.isShared
                              ? Colors.blue
                              : Colors.grey,
                    ),
                    if (food.isFeatured)
                      const Chip(
                        label: Text(
                          "🌟 Nổi bật",
                          style: TextStyle(
                              color: Colors.white),
                        ),
                        backgroundColor:
                            Colors.purple,
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                /// LIKE COUNT
                Text(
                  "❤️ ${food.likedBy.length} lượt thích",
                  style: const TextStyle(
                      fontWeight: FontWeight.w500),
                ),

                const SizedBox(height: 16),

                /// CATEGORY
                Text(
                  "Danh mục: ${food.category}",
                  style: const TextStyle(
                      fontWeight: FontWeight.w500),
                ),

                const SizedBox(height: 16),

                /// INGREDIENTS
                const Text(
                  "Nguyên liệu",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                ...food.ingredients.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4),
                    child: Text("• $item"),
                  ),
                ),

                const SizedBox(height: 16),

                /// INSTRUCTIONS
                const Text(
                  "Cách làm",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(food.instructions),

                if (food.note.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    "Ghi chú",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(food.note),
                ],

                const SizedBox(height: 24),

                /// ADMIN ACTION BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              food.isApproved
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                        onPressed: () async {
                          await provider
                              .toggleApproval(food);

                          ScaffoldMessenger.of(
                                  context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                food.isApproved
                                    ? "Đã huỷ duyệt"
                                    : "Đã duyệt bài",
                              ),
                            ),
                          );
                        },
                        child: Text(
                          food.isApproved
                              ? "Huỷ duyệt"
                              : "Duyệt bài",
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.purple,
                        ),
                        onPressed: () async {
                          await provider
                              .toggleFeatured(
                                  food);

                          ScaffoldMessenger.of(
                                  context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Đã cập nhật nổi bật"),
                            ),
                          );
                        },
                        child: Text(
                          food.isFeatured
                              ? "Bỏ nổi bật"
                              : "Đặt nổi bật",
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// DELETE BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.red,
                    ),
                    onPressed: () async {
                      final confirm =
                          await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title:
                              const Text("Xác nhận"),
                          content: const Text(
                              "Bạn có chắc muốn xoá bài này?"),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(
                                      context,
                                      false),
                              child:
                                  const Text("Huỷ"),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(
                                      context,
                                      true),
                              child:
                                  const Text("Xoá"),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await provider
                            .deleteFood(food);

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    child:
                        const Text("Xoá bài"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}