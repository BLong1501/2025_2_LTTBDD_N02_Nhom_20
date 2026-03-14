import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; // IMPORT THƯ VIỆN DỊCH
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
  bool isLoading = false; 

  @override
  void initState() {
    super.initState();

    if (widget.food != null) {
      isEdit = true;
      titleController.text = widget.food!.title;
      categoryController.text = widget.food!.category;
      ingredientsController.text = widget.food!.ingredients.join(", ");
      instructionsController.text = widget.food!.instructions;
      tagsController.text = widget.food!.tags.join(", ");
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    categoryController.dispose();
    ingredientsController.dispose();
    instructionsController.dispose();
    tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminFoodProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        // Đổi tiêu đề AppBar
        title: Text(
          isEdit ? "edit_recipe".tr() : "add_recipe".tr(), 
          style: const TextStyle(color: Colors.white)
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "food_name".tr(), border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: categoryController,
              decoration: InputDecoration(labelText: "category".tr(), border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: ingredientsController,
              maxLines: 3, 
              decoration: InputDecoration(labelText: "${'ingredients'.tr()} (,)", border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: tagsController,
              decoration: InputDecoration(labelText: "${'tag'.tr()} (,)", border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: instructionsController,
              maxLines: 5, 
              decoration: InputDecoration(labelText: "instructions".tr(), border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                onPressed: isLoading ? null : () async {
                  setState(() => isLoading = true); 

                  List<String> parsedIngredients = ingredientsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                  List<String> parsedTags = tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

                  final food = FoodModel(
                    id: widget.food?.id ?? "", 
                    authorId: widget.food?.authorId ?? "admin_id", 
                    title: titleController.text.trim(),
                    imageUrl: widget.food?.imageUrl ?? "", 
                    ingredients: parsedIngredients,
                    instructions: instructionsController.text.trim(),
                    createdAt: widget.food?.createdAt ?? DateTime.now(), 
                    category: categoryController.text.trim(),
                    tags: parsedTags,
                    isApproved: true, 
                    time: widget.food?.time ?? "30 ${'minutes'.tr()}",
                    servings: widget.food?.servings ?? "2 ${'people'.tr()}",
                    difficulty: widget.food?.difficulty ?? "medium".tr(),
                    rating: widget.food?.rating ?? 0.0,
                    likedBy: widget.food?.likedBy ?? [], 
                    note: widget.food?.note ?? "",
                    isShared: widget.food?.isShared ?? true,
                    isFeatured: widget.food?.isFeatured ?? true, 
                  );

                  try {
                    if (isEdit) {
                      await provider.updateFood(food);
                    } else {
                      await provider.addFood(food);
                    }
                    if (mounted) {
                      // Đổi thông báo thành công
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("recipe_updated".tr())));
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                  } finally {
                    if (mounted) setState(() => isLoading = false);
                  }
                },
                child: isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    // Đổi chữ trong nút
                    : Text("save".tr(), style: const TextStyle(fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}