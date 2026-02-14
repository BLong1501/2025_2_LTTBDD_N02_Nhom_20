import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_food_provider.dart';
import '../../models/food_model.dart';
import 'add_edit_food_screen.dart';


class ManageFoodsScreen extends StatefulWidget {
  const ManageFoodsScreen({super.key});

  @override
  State<ManageFoodsScreen> createState() =>
      _ManageFoodsScreenState();
}

class _ManageFoodsScreenState
    extends State<ManageFoodsScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() =>
        Provider.of<AdminFoodProvider>(context,
                listen: false)
            .fetchFoods());
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<AdminFoodProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kiểm duyệt công thức"),
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: provider.foods.length,
              itemBuilder: (context, index) {
                final FoodModel food =
                    provider.foods[index];

                return Card(
                  margin:
                      const EdgeInsets.all(8),
                  child: ListTile(
                    leading: Image.network(
                      food.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(food.title),
                    subtitle: Text(
                        "Author: ${food.authorId}\n"
                        "Status: ${food.isApproved ? "Đã duyệt" : "Bị ẩn"}"),
                    trailing:
                        PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == "delete") {
                          provider.deleteFood(food);
                        }
                        if (value == "approve") {
                          provider
                              .toggleApproval(food);
                        }
                        if (value == "edit") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditFoodScreen(food: food),
                            ),
                          );
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: "approve",
                          child: Text(
                            food.isApproved
                                ? "Ẩn bài"
                                : "Duyệt bài",
                          ),
                        ),
                        const PopupMenuItem(
                          value: "edit",
                          child: Text("Sửa"),
                        ),
                        const PopupMenuItem(
                          value: "delete",
                          child: Text("Xóa bài"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
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
