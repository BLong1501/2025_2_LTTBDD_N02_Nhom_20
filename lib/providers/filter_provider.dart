import 'package:flutter/material.dart';
import '../../models/filter_model.dart';

/// Provider để quản lý trạng thái bộ lọc trong màn hình tìm kiếm
class FilterProvider extends ChangeNotifier {
  FilterModel _filter = FilterModel();

  FilterModel get filter => _filter;

  // Cập nhật toàn bộ filter
  void setFilter(FilterModel newFilter) {
    _filter = newFilter;
    notifyListeners();
  }

  // Thêm/xóa mức độ khó
  void toggleDifficulty(String difficulty) {
    final List<String> updatedList = List.from(_filter.selectedDifficulty);
    if (updatedList.contains(difficulty)) {
      updatedList.remove(difficulty);
    } else {
      updatedList.add(difficulty);
    }
    _filter = _filter.copyWith(selectedDifficulty: updatedList);
    notifyListeners();
  }

  // Thêm/xóa danh mục
  void toggleCategory(String category) {
    final List<String> updatedList = List.from(_filter.selectedCategories);
    if (updatedList.contains(category)) {
      updatedList.remove(category);
    } else {
      updatedList.add(category);
    }
    _filter = _filter.copyWith(selectedCategories: updatedList);
    notifyListeners();
  }

  // Thêm/xóa tag
  void toggleTag(String tag) {
    final List<String> updatedList = List.from(_filter.selectedTags);
    if (updatedList.contains(tag)) {
      updatedList.remove(tag);
    } else {
      updatedList.add(tag);
    }
    _filter = _filter.copyWith(selectedTags: updatedList);
    notifyListeners();
  }

  // Xóa tất cả bộ lọc
  void clearAllFilters() {
    _filter = FilterModel();
    notifyListeners();
  }

  // Kiểm tra có bộ lọc nào đang hoạt động
  bool hasActiveFilters() {
    return _filter.hasActiveFilters();
  }

  // Reset provider
  void reset() {
    _filter = FilterModel();
    notifyListeners();
  }
}
