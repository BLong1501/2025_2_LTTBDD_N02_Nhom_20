import 'package:cloud_firestore/cloud_firestore.dart';

// Định nghĩa trạng thái báo cáo
enum ReportStatus { pending, resolved, dismissed }

class ReportModel {
  final String id;
  final String reporterId; // ID người báo cáo
  final String targetId;   // ID bài viết/comment/user bị báo cáo
  final String reason;     // Lý do
  final ReportStatus status; // Trạng thái xử lý
  final DateTime createdAt; // Thời gian tạo

  ReportModel({
    required this.id,
    required this.reporterId,
    required this.targetId,
    required this.reason,
    this.status = ReportStatus.pending, // Mặc định là đang chờ xử lý
    required this.createdAt,
  });

  // 1. Chuyển từ Firestore Map sang Object
  factory ReportModel.fromMap(Map<String, dynamic> data, String docId) {
    return ReportModel(
      id: docId,
      reporterId: data['reporterId'] ?? '',
      targetId: data['targetId'] ?? '',
      reason: data['reason'] ?? '',
      
      // Quan trọng: Chuyển String ('pending') thành Enum (ReportStatus.pending)
      status: ReportStatus.values.firstWhere(
        (e) => e.name == data['status'], 
        orElse: () => ReportStatus.pending // Nếu lỗi dữ liệu thì về mặc định
      ),
      
      // Chuyển Timestamp thành DateTime
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // 2. Chuyển từ Object sang Map để lưu lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'reporterId': reporterId,
      'targetId': targetId,
      'reason': reason,
      
      // Quan trọng: Lưu Enum dưới dạng String ('pending', 'resolved', ...)
      'status': status.name, 
      
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}