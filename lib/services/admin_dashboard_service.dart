import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/dashboard_model.dart';

class AdminDashboardService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  DashboardModel? model;

  /// LOAD TOÀN BỘ DASHBOARD
  Future<void> loadDashboardData() async {
    try {
      isLoading = true;
      notifyListeners();

      final now = DateTime.now();

      final usersSnapshot =
          await _firestore.collection('users').get();

      final foodsSnapshot =
          await _firestore.collection('foods').get();

      final pendingSnapshot = await _firestore
          .collection('foods')
          .where('status', isEqualTo: 'pending')
          .get();

      final featuredSnapshot = await _firestore
          .collection('foods')
          .where('isFeatured', isEqualTo: true)
          .get();

      List<int> monthlyPending = List.filled(12, 0);
      List<int> monthlyApproved = List.filled(12, 0);

      for (var doc in foodsSnapshot.docs) {
        final data = doc.data();

        final status = (data['status'] ?? '').toString().toLowerCase();
        final Timestamp? timestamp = data['createdAt'];
        if (timestamp == null) continue;
        DateTime date = timestamp.toDate();
        if (date.year != now.year) continue;
        int monthIndex = date.month - 1;
        if (status == 'pending') {
          monthlyPending[monthIndex]++;
        } else if (status == 'approved') {
          monthlyApproved[monthIndex]++;
        }
      }

      model = DashboardModel(
        totalUsers: usersSnapshot.docs.length,
        totalFoods: foodsSnapshot.docs.length,
        pendingFoods: pendingSnapshot.docs.length,
        featuredFoods: featuredSnapshot.docs.length,
        monthlyPending: monthlyPending,
        monthlyApproved: monthlyApproved,
      );

      isLoading = false;
      notifyListeners();

    } catch (e) {
      isLoading = false;
      notifyListeners();
      debugPrint("Dashboard Error: $e");
    }
  } 
}