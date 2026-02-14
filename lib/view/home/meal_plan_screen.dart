import 'package:btl_ltdd/view/food/meal_plan_detail.screen.dart';
import 'package:flutter/material.dart';
import '../../models/meal_plan_model.dart';
import '../../services/meal_plan_service.dart';
import '../food/add_food_screen.dart'; // Import màn hình thêm món
// import '../food/meal_plan_detail_screen.dart'; // Import màn hình chi tiết

class MealPlansScreen extends StatefulWidget {
  const MealPlansScreen({super.key});

  @override
  State<MealPlansScreen> createState() => _MealPlansScreenState();
}

class _MealPlansScreenState extends State<MealPlansScreen> {
  final MealPlanService _service = MealPlanService();

  // --- SỬA HÀM NÀY: Chỉ chuyển trang, không tạo Plan ---
  void _goToAddFoodScreen() {
    // Chuyển sang màn hình AddFoodScreen với planId là RỖNG
    Navigator.push(
      context,
      MaterialPageRoute(
        // planId rỗng ('') báo hiệu cho AddFoodScreen biết là cần tạo Plan mới khi lưu
        builder: (_) => const AddFoodScreen(planId: ''), 
      ),
    );
  }
  // -----------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: StreamBuilder<List<MealPlanModel>>(
        stream: _service.getMyPlansStream(),
        builder: (context, snapshot) {
          final plans = snapshot.hasData ? snapshot.data! : [];
          final planCount = plans.length;

          return Column(
            children: [
              // 1. HEADER CAM & NÚT TẠO
              _buildCustomHeader(planCount),

              // 2. DANH SÁCH
              Expanded(
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : plans.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            itemCount: plans.length,
                            itemBuilder: (context, index) {
                              return _buildPlanCard(plans[index]);
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget: Header màu cam và Nút tạo nổi
  Widget _buildCustomHeader(int count) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Nền cam gradient
        Container(
          padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 50),
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF6F00), Color(0xFFFF3D00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.soup_kitchen, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Cooky",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const Padding(
                padding: EdgeInsets.only(left: 50),
                child: Text(
                  "Kế hoạch bữa ăn",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ],
          ),
        ),

        // Nút "Tạo kế hoạch mới" nằm đè lên
        Positioned(
          bottom: -25,
          left: 20,
          right: 20,
          child: InkWell(
            onTap: _goToAddFoodScreen, // <--- GỌI HÀM MỚI Ở ĐÂY
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(color: Colors.orange.shade100, width: 1),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.deepOrange),
                  SizedBox(width: 8),
                  Text(
                    "Tạo kế hoạch mới",
                    style: TextStyle(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget: Thẻ hiển thị từng kế hoạch
  Widget _buildPlanCard(MealPlanModel plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MealPlanDetailScreen(plan: plan),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      plan.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _showDeleteDialog(plan),
                  )
                ],
              ),
              const SizedBox(height: 12),
              Text(
                plan.note.isNotEmpty ? plan.note : "Chưa có mô tả chi tiết...",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    _getRelativeTime(plan.createdAt),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Widget: Trạng thái trống
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(Icons.edit_calendar_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 15),
          const Text("Bạn chưa có kế hoạch nào", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // Hộp thoại xóa
  void _showDeleteDialog(MealPlanModel plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xóa kế hoạch?"),
        content: Text("Bạn có chắc muốn xóa '${plan.name}' không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          TextButton(
            onPressed: () {
              _service.deletePlan(plan.id);
              Navigator.pop(ctx);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Hàm tính thời gian
  String _getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays > 0) return "${difference.inDays} ngày trước";
    if (difference.inHours > 0) return "${difference.inHours} giờ trước";
    if (difference.inMinutes > 0) return "${difference.inMinutes} phút trước";
    return "Vừa xong";
  }
}