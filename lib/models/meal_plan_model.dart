import 'package:cloud_firestore/cloud_firestore.dart';

class MealPlanModel {
  final String id;
  final String userId;    // ID của người tạo plan này
  final String name;      // Tên plan (VD: "Thực đơn giảm cân", "Tuần 1")
  final String note;      // Ghi chú ngắn
  final DateTime createdAt;
  // Sau này bạn có thể thêm List<String> recipeIds để lưu các món ăn vào đây

  MealPlanModel({
    required this.id,
    required this.userId,
    required this.name,
    this.note = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory MealPlanModel.fromMap(Map<String, dynamic> data, String docId) {
    return MealPlanModel(
      id: docId,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      note: data['note'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}