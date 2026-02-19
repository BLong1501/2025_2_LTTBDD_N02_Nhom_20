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
  final List<String> tags;      // Thẻ gắn kèm món ăn
  final String category;        // Danh mục món ăn
  final bool isApproved; // Admin duyệt hay chưa
  final String time;       // Ví dụ: "15 phút", "1 giờ"
  final String servings;   // Ví dụ: "2 người", "4-5 người"
  final String difficulty; // Ví dụ: "Dễ", "Trung bình", "Khó"
  

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
    this.tags = const [],
    this.category = '',
    this.isApproved = true,
    this.time = "", 
    this.servings = "", 
    this.difficulty = "Dễ",
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
      // Xử lý an toàn hơn để tránh lỗi nếu createdAt bị null
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),

      // Ép kiểu danh sách thẻ
      tags: List<String>.from(data['tags'] ?? []),
      category: data['category'] ?? '',
      isApproved: data['isApproved'] ?? true,

      // --- BỔ SUNG 3 TRƯỜNG MỚI VÀO ĐÂY ---
      time: data['time'] ?? '15 phút',
      servings: data['servings'] ?? '2 người',
      difficulty: data['difficulty'] ?? 'Dễ',
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
      'tags': tags,
      'category': category,
      'isApproved': isApproved,

      // --- BỔ SUNG 3 TRƯỜNG MỚI VÀO ĐÂY ---
      'time': time,
      'servings': servings,
      'difficulty': difficulty,
    };
  }
  
  // 3. Hàm copyWith
  FoodModel copyWith({
    String? id,
    String? authorId,
    String? title,
    String? imageUrl,
    List<String>? ingredients,
    String? instructions,
    String? note,
    bool? isShared,
    List<String>? likedBy,
    DateTime? createdAt,
    List<String>? tags,
    String? category,
    bool? isApproved,
    
    // --- BỔ SUNG 3 TRƯỜNG MỚI VÀO ĐÂY ---
    String? time,
    String? servings,
    String? difficulty,
  }) {
    return FoodModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      note: note ?? this.note,
      isShared: isShared ?? this.isShared,
      likedBy: likedBy ?? this.likedBy,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      isApproved: isApproved ?? this.isApproved,
      
      // --- BỔ SUNG 3 TRƯỜNG MỚI VÀO ĐÂY ---
      time: time ?? this.time,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}