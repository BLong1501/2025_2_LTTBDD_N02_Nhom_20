import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/food_model.dart';

class FoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Thêm món ăn vào một Plan cụ thể
  Future<void> addFoodToPlan(String planId, FoodModel food) async {
    // Lưu vào đường dẫn: meal_plans/{planId}/foods/{foodId}
    await _firestore
        .collection('meal_plans')
        .doc(planId)
        .collection('foods')
        .add(food.toMap());
  }

  // 2. Lấy danh sách món ăn của Plan đó
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

  // 3. Xóa món ăn khỏi Plan
  Future<void> deleteFood(String planId, String foodId) async {
    await _firestore
        .collection('meal_plans')
        .doc(planId)
        .collection('foods')
        .doc(foodId)
        .delete();
  }
}