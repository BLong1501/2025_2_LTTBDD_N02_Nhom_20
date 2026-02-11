import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String foodId;      // ID món ăn
  final String userId;      // ID người bình luận
  final String userName;    // Tên người bình luận (Lưu cứng để đỡ query lại)
  final String? userAvatar; // (Nên thêm) Ảnh đại diện người bình luận
  final String content;     // Nội dung
  final DateTime createdAt; // Thời gian tạo

  CommentModel({
    required this.id,
    required this.foodId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    required this.createdAt,
  });

  // 1. Hàm chuyển từ Firestore Map sang Object (Dùng khi lấy dữ liệu về)
  factory CommentModel.fromMap(Map<String, dynamic> map, String docId) {
    return CommentModel(
      id: docId, // Lấy ID từ Document ID của Firestore
      foodId: map['foodId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Người dùng ẩn danh',
      userAvatar: map['userAvatar'], // Có thể null
      content: map['content'] ?? '',
      // Quan trọng: Chuyển Timestamp của Firestore thành DateTime của Dart
      createdAt: (map['createdAt'] as Timestamp).toDate(), 
    );
  }

  // 2. Hàm chuyển từ Object sang Map (Dùng khi lưu dữ liệu lên)
  Map<String, dynamic> toMap() {
    return {
      'foodId': foodId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      // Quan trọng: Lưu DateTime dưới dạng Timestamp server
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}