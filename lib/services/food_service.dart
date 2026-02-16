import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/food_model.dart';

class FoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // =================================================================
  // PHẦN 1: QUẢN LÝ MÓN ĂN CHUNG (Lưu vào collection 'foods')
  // Dùng cho màn hình danh sách món ăn chính (MealPlansScreen cũ)
  // =================================================================

  // 1.1. Lấy tất cả món ăn của User
  Stream<List<FoodModel>> getAllUserFoods() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('foods') // Lưu ở collection gốc
        .where('authorId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FoodModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // 1.2. Thêm món ăn vào danh sách chung
  Future<void> addFood(FoodModel food) async {
    await _firestore.collection('foods').add(food.toMap());
  }

  // 1.3. Xóa món ăn khỏi danh sách chung
  Future<void> deleteFood(String foodId) async {
    await _firestore.collection('foods').doc(foodId).delete();
  }

  // =================================================================
  // PHẦN 2: QUẢN LÝ MÓN ĂN TRONG KẾ HOẠCH (Code cũ của bạn)
  // Dùng cho MealPlanDetailScreen nếu bạn vẫn muốn giữ logic cũ
  // =================================================================

  // 2.1. Thêm món ăn vào Plan cụ thể (Sub-collection)
  Future<void> addFoodToPlan(String planId, FoodModel food) async {
    await _firestore
        .collection('meal_plans')
        .doc(planId)
        .collection('foods')
        .add(food.toMap());
  }

  // 2.2. Lấy món ăn của một Plan cụ thể
  Stream<List<FoodModel>> getFoodsInPlan(String planId) {
    return _firestore
        .collection('meal_plans')
        .doc(planId)
        .collection('foods')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FoodModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // 2.3. Xóa món ăn khỏi Plan
  Future<void> deleteFoodFromPlan(String planId, String foodId) async {
    await _firestore
        .collection('meal_plans')
        .doc(planId)
        .collection('foods')
        .doc(foodId)
        .delete();
  }
  Stream<List<FoodModel>> getCommunityFoods() {
    return _firestore
        .collection('foods')
        .where('isShared', isEqualTo: true) // Chỉ lấy bài chia sẻ công khai
        .orderBy('createdAt', descending: true) // Bài mới nhất lên đầu
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FoodModel.fromMap(doc.data(), doc.id))
            .toList());
  }
  Future<void> toggleLike(String foodId, List<String> currentLikes) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final String uid = user.uid;
    List<String> newLikes = List.from(currentLikes);

    if (newLikes.contains(uid)) {
      newLikes.remove(uid); // Nếu đã like thì bỏ like
    } else {
      newLikes.add(uid); // Chưa like thì thêm vào
    }

    // Cập nhật lại mảng likedBy trên Firestore
    await _firestore.collection('foods').doc(foodId).update({
      'likedBy': newLikes,
    });
  }
}