import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_model.dart';

class AdminFoodProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<FoodModel> _foods = [];
  bool _isLoading = false;

  // getters
  List<FoodModel> get foods => _foods;
  bool get isLoading => _isLoading;

  // LOAD TẤT CẢ FOODS
  Future<void> fetchFoods() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('foods')
          .orderBy('createdAt', descending: true)
          .get();

      _foods = snapshot.docs
          .map((doc) => FoodModel.fromMap(doc.data(), doc.id))
          .toList();

    } catch (e) {
      debugPrint("Fetch foods error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // XÓA FOOD
  Future<void> deleteFood(FoodModel food) async {
    try {
      await _firestore
          .collection('foods')
          .doc(food.id)
          .delete();

      _foods.removeWhere((f) => f.id == food.id);

      notifyListeners();

    } catch (e) {
      debugPrint("Delete food error: $e");
    }
  }

  // DUYỆT / ẨN FOOD
  Future<void> toggleApproval(FoodModel food) async {
    try {
      final updatedFood = food.copyWith(
        isApproved: !food.isApproved,
      );

      await _firestore
          .collection('foods')
          .doc(food.id)
          .update({
        'isApproved': updatedFood.isApproved,
      });

      final index =
          _foods.indexWhere((f) => f.id == food.id);

      if (index != -1) {
        _foods[index] = updatedFood;
        notifyListeners();
      }

    } catch (e) {
      debugPrint("Toggle approval error: $e");
    }
  }
}
