import 'package:cloud_firestore/cloud_firestore.dart';

class LogModel {
  final String id;
  final String adminId;     // ID của Admin thực hiện hành động
  final String action;      // Nội dung hành động (VD: "Khóa User A", "Duyệt bài B")
  final DateTime timestamp; // Thời gian thực hiện

  LogModel({
    required this.id,
    required this.adminId,
    required this.action,
    required this.timestamp,
  });

  // 1. Chuyển từ Firestore Map sang Object (Khi đọc log về hiển thị)
  factory LogModel.fromMap(Map<String, dynamic> data, String docId) {
    return LogModel(
      id: docId, // Lấy ID từ tên document
      adminId: data['adminId'] ?? '',
      action: data['action'] ?? '',
      // Chuyển Timestamp của Firestore thành DateTime
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  // 2. Chuyển từ Object sang Map (Khi Admin thực hiện xong thì lưu lại)
  Map<String, dynamic> toMap() {
    return {
      'adminId': adminId,
      'action': action,
      // Chuyển DateTime thành Timestamp để lưu lên Firestore
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}