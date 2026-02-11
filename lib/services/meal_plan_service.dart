import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/meal_plan_model.dart';

class MealPlanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Tạo Plan mới
  Future<void> createPlan(String name, String note) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final newPlan = MealPlanModel(
      id: '', // Firestore sẽ tự sinh ID
      userId: user.uid,
      name: name,
      note: note,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('meal_plans').add(newPlan.toMap());
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