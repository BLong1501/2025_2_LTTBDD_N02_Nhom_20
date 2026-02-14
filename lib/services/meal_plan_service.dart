import 'package:btl_ltdd/models/food_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/meal_plan_model.dart';

class MealPlanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Tạo Plan mới
  
 Future<void> createPlanWithFirstFood(FoodModel firstFood) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // 1. Tạo dữ liệu cho Plan mới (Tên mặc định theo ngày)
    final now = DateTime.now();
    final String defaultPlanName = "Thực đơn ngày ${now.day}/${now.month}";
    
    final newPlan = MealPlanModel(
      id: '',
      userId: user.uid,
      name: defaultPlanName,
      note: "Được tạo tự động khi thêm món: ${firstFood.title}",
      createdAt: now,
    );

    // 2. Thực hiện Batch Write (Ghi nhiều lệnh cùng lúc để đảm bảo an toàn dữ liệu)
    WriteBatch batch = _firestore.batch();

    // A. Tạo Document cho Plan
    DocumentReference planRef = _firestore.collection('meal_plans').doc(); // Tự sinh ID
    batch.set(planRef, newPlan.toMap());

    // B. Tạo Document cho Food bên trong Plan đó
    DocumentReference foodRef = planRef.collection('foods').doc(); // Tự sinh ID
    batch.set(foodRef, firstFood.toMap());

    // 3. Thực thi
    await batch.commit();
  }

  // 2. Lấy danh sách Plan của User hiện tại (Realtime)
  Stream<List<MealPlanModel>> getMyPlansStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('meal_plans')
        .where('userId', isEqualTo: user.uid) // Chỉ lấy plan của mình
        .orderBy('createdAt', descending: true) // Mới nhất lên đầu
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MealPlanModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // 3. Xóa Plan
  Future<void> deletePlan(String planId) async {
    await _firestore.collection('meal_plans').doc(planId).delete();
  }
}