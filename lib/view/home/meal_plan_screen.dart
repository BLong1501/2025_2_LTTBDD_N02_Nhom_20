import 'package:btl_ltdd/view/food/meal_plan_detail.screen.dart';
import 'package:flutter/material.dart';
import '../../models/meal_plan_model.dart';
import '../../services/meal_plan_service.dart';
// import '../food/meal_plan_detail_screen.dart'; // Import màn hình chi tiết

class MealPlansScreen extends StatefulWidget {
  const MealPlansScreen({super.key});

  @override
  State<MealPlansScreen> createState() => _MealPlansScreenState();
}

class _MealPlansScreenState extends State<MealPlansScreen> {
  final MealPlanService _service = MealPlanService();

  // Hộp thoại tạo mới
  void _showAddDialog() {
    final nameController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tạo thực đơn mới"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Tên (VD: Tuần giảm cân)"),
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: "Ghi chú"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await _service.createPlan(nameController.text.trim(), noteController.text.trim());
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text("Tạo"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Thực đơn của tôi"), backgroundColor: Colors.white, elevation: 0),
      body: StreamBuilder<List<MealPlanModel>>(
        stream: _service.getMyPlansStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Chưa có thực đơn nào"));
          }
          final plans = snapshot.data!;
          return ListView.builder(
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              return ListTile(
                leading: const Icon(Icons.restaurant_menu, color: Colors.orange),
                title: Text(plan.name),
                subtitle: Text(plan.note),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _service.deletePlan(plan.id),
                ),
                onTap: () {
                  // Chuyển sang màn hình chi tiết món ăn
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MealPlanDetailScreen(plan: plan)),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}