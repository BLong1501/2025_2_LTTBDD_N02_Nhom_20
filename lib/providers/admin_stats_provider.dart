import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminStatsProvider extends ChangeNotifier {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  int totalUsers = 0;
  int totalFoods = 0;
  int pendingFoods = 0;

  bool isLoading = false;

  Future<void> fetchStats() async {

    isLoading = true;
    notifyListeners();

    try {

      // Đếm users
      final usersSnapshot =
          await _firestore.collection('users').get();

      totalUsers = usersSnapshot.docs.length;

      // Đếm foods
      final foodsSnapshot =
          await _firestore.collection('foods').get();

      totalFoods = foodsSnapshot.docs.length;

      // Đếm foods chưa duyệt
      final pendingSnapshot =
          await _firestore
              .collection('foods')
              .where('isApproved', isEqualTo: false)
              .get();

      pendingFoods = pendingSnapshot.docs.length;

    } catch (e) {

      print("Error fetching stats: $e");

    }

    isLoading = false;
    notifyListeners();
  }
}
