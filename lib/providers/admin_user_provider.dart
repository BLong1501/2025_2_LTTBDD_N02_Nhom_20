import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AdminUserProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<UserModel> _users = [];
  bool _isLoading = false;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;

  // Load toàn bộ user từ Firestore
  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('users').get();

      _users = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint("Fetch users error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // Khóa / Mở khóa user
  Future<void> toggleLockUser(UserModel user) async {
    final updatedUser =
        user.copyWith(isLocked: !user.isLocked);

    await _firestore
        .collection('users')
        .doc(user.id)
        .update({'isLocked': updatedUser.isLocked});

    final index =
        _users.indexWhere((u) => u.id == user.id);

    if (index != -1) {
      _users[index] = updatedUser;
      notifyListeners();
    }
  }

  // Đổi role user
  Future<void> changeUserRole(UserModel user) async {
    final newRole = user.role == UserRole.admin
        ? UserRole.blogger
        : UserRole.admin;

    final updatedUser = user.copyWith(role: newRole);

    await _firestore
        .collection('users')
        .doc(user.id)
        .update({'role': newRole.name});

    final index =
        _users.indexWhere((u) => u.id == user.id);

    if (index != -1) {
      _users[index] = updatedUser;
      notifyListeners();
    }
  }
}
