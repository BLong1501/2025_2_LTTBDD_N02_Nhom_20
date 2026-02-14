import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_food_provider.dart';
import '../../models/food_model.dart';

class AddEditFoodScreen extends StatefulWidget {
  final FoodModel? food;

  const AddEditFoodScreen({super.key, this.food});

  @override
  State<AddEditFoodScreen> createState() => _AddEditFoodScreenState();
}

class _AddEditFoodScreenState extends State<AddEditFoodScreen> {

  final titleController = TextEditingController();
  final categoryController = TextEditingController();
  final ingredientsController = TextEditingController();
  final instructionsController = TextEditingController();
  final tagsController = TextEditingController();

  bool isEdit = false;

  @override
  void initState() {
    super.initState();

    if (widget.food != null) {
      isEdit = true;

      titleController.text = widget.food!.title;
      categoryController.text = widget.food!.category;
      ingredientsController.text =
          widget.food!.ingredients.join(",");
      instructionsController.text =
          widget.food!.instructions;
      tagsController.text =
          widget.food!.tags.join(",");
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<AdminFoodProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit
            ? "Sửa công thức"
            : "Thêm công thức"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: titleController,
              decoration:
                  const InputDecoration(labelText: "Tên món"),
            ),

            TextField(
              controller: categoryController,
              decoration:
                  const InputDecoration(labelText: "Category"),
            ),

            TextField(
              controller: ingredientsController,
              decoration:
                  const InputDecoration(
                      labelText: "Ingredients (phân cách bằng ,)"),
            ),

            TextField(
              controller: tagsController,
              decoration:
                  const InputDecoration(
                      labelText: "Tags (phân cách bằng ,)"),
            ),

            TextField(
              controller: instructionsController,
              decoration:
                  const InputDecoration(labelText: "Instructions"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {

                final food = FoodModel(
                  id: widget.food?.id ?? "",
                  authorId: "admin",
                  title: titleController.text,
                  imageUrl: "",
                  ingredients:
                      ingredientsController.text.split(","),
                  instructions:
                      instructionsController.text,
                  createdAt: DateTime.now(),
                  category: categoryController.text,
                  tags: tagsController.text.split(","),
                  isApproved: true,
                );

                if (isEdit) {
                  await provider.updateFood(food);
                } else {
                  await provider.addFood(food);
                }

                Navigator.pop(context);
              },
              child: Text(isEdit ? "Cập nhật" : "Thêm"),
            )
          ],
        ),
      ),
    );
  }
}
