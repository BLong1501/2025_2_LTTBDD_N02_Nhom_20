import 'package:flutter/material.dart';
import 'package:btl_ltdd/models/dashboard_model.dart';
class AdminDashboardProvider extends ChangeNotifier {
  DashboardModel _data = DashboardModel.empty();

  DashboardModel get data => _data;

  void setData(DashboardModel newData) {
    _data = newData;
    notifyListeners();
  }
}