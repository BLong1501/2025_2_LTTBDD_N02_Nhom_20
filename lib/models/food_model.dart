import 'package:cloud_firestore/cloud_firestore.dart';

class FoodModel {
  final String id;
  final String authorId;      // ID người tạo (Blogger)
  final String title;         // Tên món ăn
  final String imageUrl;      // Ảnh món ăn
  final List<String> ingredients; // Nguyên liệu
  final String instructions;      // Cách làm
  final String note;              // Ghi chú cá nhân
  final bool isShared;            // Trạng thái chia sẻ (Public/Private)
  final List<String> likedBy;     // Danh sách ID người thả tim
  final DateTime createdAt;       // Thời gian tạo

  FoodModel({
    required this.id,
    required this.authorId,
    required this.title,
    required this.imageUrl,
    required this.ingredients,
    required this.instructions,
    this.note = '',
    this.isShared = false,
    this.likedBy = const [],
    required this.createdAt,
  });

  // 1. Chuyển từ Firestore Map sang Object
  factory FoodModel.fromMap(Map<String, dynamic> data, String docId) {
    return FoodModel(
      id: docId, // Lấy ID từ tên document
      authorId: data['authorId'] ?? '',
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      
      // Quan trọng: Phải dùng List.from để ép kiểu từ dynamic sang String
      ingredients: List<String>.from(data['ingredients'] ?? []),
      
      instructions: data['instructions'] ?? '',
      note: data['note'] ?? '',
      isShared: data['isShared'] ?? false,
      
      // Tương tự, ép kiểu danh sách người like
      likedBy: List<String>.from(data['likedBy'] ?? []),
      
      // Chuyển Timestamp của Firebase thành DateTime
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // 2. Chuyển từ Object sang Map để lưu lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'title': title,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'instructions': instructions,
      'note': note,
      'isShared': isShared,
      'likedBy': likedBy,
      'createdAt': Timestamp.fromDate(createdAt), // Chuyển ngược lại thành Timestamp
    };
  }
}