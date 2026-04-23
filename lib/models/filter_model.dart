class FilterModel {
  List<String> selectedDifficulty; // Mức độ: ['Dễ', 'Trung bình', 'Khó']
  List<String> selectedCategories; // Loại món: ['Món chính', 'Món phụ', 'Tráng miệng', ...]
  List<String> selectedTags; // Các tag được chọn
  
  FilterModel({
    this.selectedDifficulty = const [],
    this.selectedCategories = const [],
    this.selectedTags = const [],
  });

  // Kiểm tra có bộ lọc nào được áp dụng không
  bool hasActiveFilters() {
    return selectedDifficulty.isNotEmpty || 
           selectedCategories.isNotEmpty || 
           selectedTags.isNotEmpty;
  }

  // Copy with để cập nhật filter
  FilterModel copyWith({
    List<String>? selectedDifficulty,
    List<String>? selectedCategories,
    List<String>? selectedTags,
  }) {
    return FilterModel(
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedTags: selectedTags ?? this.selectedTags,
    );
  }

  // Xóa tất cả filter
  void clearFilters() {
    selectedDifficulty = [];
    selectedCategories = [];
    selectedTags = [];
  }
}
