import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/food_model.dart';
class DiscoverProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<FoodModel> _discoverFoods = [];
  List<FoodModel> get discoverFoods => _discoverFoods;

  Future<void> fetchDiscoverFoods() async {
    final snapshot = await _firestore
        .collection('foods')
        .where('isApproved', isEqualTo: true)
        .where('isFeatured', isEqualTo: true)
        .get();

    _discoverFoods = snapshot.docs
        .map((doc) => FoodModel.fromMap(doc.data(), doc.id))
        .toList();

    notifyListeners();
  }
}