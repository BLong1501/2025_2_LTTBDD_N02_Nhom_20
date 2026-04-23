# 🏗️ Tài liệu kỹ thuật - Tính năng Tìm kiếm & Lọc nâng cao

## 📋 Mục lục
1. [Kiến trúc](#kiến-trúc)
2. [Chi tiết các file](#chi-tiết-các-file)
3. [Luồng dữ liệu](#luồng-dữ-liệu)
4. [API & Phương thức](#api--phương-thức)
5. [Ví dụ sử dụng](#ví-dụ-sử-dụng)

---

## 🏛️ Kiến trúc

### Tổng quan
```
┌─────────────────────────────────────────────────┐
│        DiscoverView (Trang chủ tìm kiếm)        │
└────────────────────┬────────────────────────────┘
                     │
                     ↓ (Người dùng nhấn tìm kiếm)
┌─────────────────────────────────────────────────┐
│  SearchResultsWithFiltersScreen (Màn hình kết quả) │
├─────────────────────────────────────────────────┤
│  - Thanh Filter Button (góc phải AppBar)        │
│  - Thanh Tag (dưới AppBar)                      │
│  - Danh sách bộ lọc hoạt động                   │
│  - Grid kết quả món ăn (có filter áp dụng)      │
└─────────────────────────────────────────────────┘
        │                    │
        ↓                    ↓
  [FilterBottomSheet]   [FilterModel/Provider]
   (Giao diện lọc)      (Quản lý state)
```

---

## 📁 Chi tiết các file

### 1. **`lib/models/filter_model.dart`**
Model để lưu trữ trạng thái bộ lọc

**Các thuộc tính**:
- `selectedDifficulty: List<String>` - Mức độ được chọn
- `selectedCategories: List<String>` - Danh mục được chọn
- `selectedTags: List<String>` - Tag được chọn

**Các phương thức**:
```dart
bool hasActiveFilters()  // Kiểm tra có bộ lọc nào
FilterModel copyWith()   // Tạo copy với các thay đổi
void clearFilters()      // Xóa tất cả bộ lọc
```

### 2. **`lib/providers/filter_provider.dart`**
Provider để quản lý state bộ lọc với `ChangeNotifier`

**Các phương thức chính**:
```dart
void setFilter(FilterModel)        // Cập nhật filter
void toggleDifficulty(String)      // Bật/tắt mức độ
void toggleCategory(String)        // Bật/tắt danh mục
void toggleTag(String)             // Bật/tắt tag
void clearAllFilters()             // Xóa tất cả
void reset()                        // Reset provider
```

### 3. **`lib/view/widgets/filter_widget.dart`**
Widget hiển thị popup lọc

**Các thành phần**:
- `FilterBottomSheet` - StatefulWidget chính
  - Header với nút "Clear all"
  - Section lọc mức độ (FilterChip)
  - Section lọc danh mục (FilterChip)
  - Nút "Apply Filters"
- `CustomFilterChip` - Widget chip tùy chỉnh

**Callback**:
```dart
Function(FilterModel) onFilterChanged  // Gọi khi nhấn Apply
```

### 4. **`lib/view/food/search_results_with_filters_screen.dart`**
Màn hình kết quả tìm kiếm với lọc

**Các thành phần**:
- `SearchResultsWithFiltersScreen` - StatefulWidget
  - AppBar với nút Filter Button
  - Thanh Tag (horizontal scroll)
  - Container hiển thị bộ lọc hoạt động
  - GridView kết quả

**Trạng thái**:
```dart
FilterModel _currentFilter          // Bộ lọc hiện tại
List<String> _availableTags         // Danh sách tag
String _selectedTagFilter           // Tag được chọn
```

---

## 🔄 Luồng dữ liệu

### 1. **Bắt đầu tìm kiếm**
```
User nhập từ khóa
    ↓
TextField.onSubmitted()
    ↓
_goToSearchResults(keyword)
    ↓
Navigator.push(SearchResultsWithFiltersScreen)
```

### 2. **Lọc dữ liệu**
```
User chọn filter option
    ↓
FilterBottomSheet -> setState()
    ↓
User nhấn "Apply Filters"
    ↓
onFilterChanged callback
    ↓
SearchResultsWithFiltersScreen -> setState() + _currentFilter
    ↓
_filterFoods() lọc danh sách
    ↓
GridView rebuild với dữ liệu mới
```

### 3. **Tìm kiếm theo Tag**
```
_loadAvailableTags() (lần đầu)
    ↓
Lấy tất cả tag từ Firestore
    ↓
Hiển thị thanh Tag
    ↓
User nhấn tag
    ↓
setState(_selectedTagFilter = tag)
    ↓
_filterFoods() áp dụng lọc tag
    ↓
GridView rebuild
```

---

## 🔍 Hàm `_filterFoods()` - Chi tiết lọc

```dart
List<DocumentSnapshot> _filterFoods(List<DocumentSnapshot> foods) {
  // 1. Lọc theo tìm kiếm (tên + nguyên liệu)
  // 2. Lọc theo mức độ khó
  // 3. Lọc theo danh mục
  // 4. Lọc theo tag
  // 5. Chỉ hiện bài Admin (isFeatured) hoặc chia sẻ (isShared)
  
  return foods.where((doc) { ... }).toList();
}
```

**Điều kiện lọc**:
- Tìm kiếm: So sánh title + ingredients (bỏ dấu)
- Mức độ: Nếu selectedDifficulty không rỗng → phải match
- Danh mục: Nếu selectedCategories không rỗng → phải match
- Tag: Nếu _selectedTagFilter không rỗng → phải match
- Trạng thái: isFeatured = true HOẶC isShared = true

---

## 📡 API & Phương thức

### FoodModel (cần có các trường)
```dart
String title                    // Tên món
String category                 // Loại món: "Món chính", "Món phụ", ...
String difficulty              // Mức độ: "Dễ", "Trung bình", "Khó"
List<String> tags              // Danh sách tag: ["nướng", "cay", ...]
List<String> ingredients       // Nguyên liệu
bool isFeatured               // Bài Admin
bool isShared                 // Bài chia sẻ
bool isApproved               // Được duyệt
double rating                 // Đánh giá
String imageUrl               // URL ảnh
```

### Firestore Query
```dart
// Lấy tất cả bài được duyệt
FirebaseFirestore.instance
    .collection('foods')
    .where('isApproved', isEqualTo: true)
    .snapshots()
```

---

## 💻 Ví dụ sử dụng

### 1. **Sử dụng FilterModel trong State**
```dart
class _SearchResultsWithFiltersScreenState ... {
  late FilterModel _currentFilter;
  
  @override
  void initState() {
    _currentFilter = FilterModel();  // Khởi tạo rỗng
  }
  
  void _applyFilter(FilterModel newFilter) {
    setState(() {
      _currentFilter = newFilter;
    });
  }
}
```

### 2. **Gọi FilterBottomSheet**
```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => FilterBottomSheet(
    initialFilter: _currentFilter,
    onFilterChanged: _applyFilter,
  ),
);
```

### 3. **Lọc danh sách**
```dart
List<DocumentSnapshot> filtered = _filterFoods(allFoods);
// Sử dụng filtered trong GridView
```

### 4. **Sử dụng Provider (tương lai)**
```dart
// Nếu muốn dùng Provider package
context.read<FilterProvider>().setFilter(newFilter);
```

---

## 🎨 Localization Keys

Các key được thêm vào `en.json` và `vi.json`:

```json
{
  "filters": "Filters" / "Bộ lọc",
  "clear_all": "Clear all" / "Xóa tất cả",
  "apply_filters": "Apply Filters" / "Áp dụng bộ lọc",
  "active_filters": "Active Filters" / "Bộ lọc đang hoạt động",
  "search_results": "Search Results" / "Kết quả tìm kiếm",
  "no_recipes": "No recipes" / "Không có công thức",
  "no_results_with_filters": "No results matching your filters" / "Không có kết quả phù hợp",
  "all": "All" / "Tất cả"
}
```

---

## 🔧 Mở rộng & Tùy chỉnh

### Thêm bộ lọc mới
```dart
// Trong FilterModel
List<String> selectedNewFilter; // Thêm trường mới

// Trong FilterBottomSheet
// Thêm section UI mới

// Trong _filterFoods()
// Thêm điều kiện lọc mới
```

### Thay đổi màu sắc
```dart
// Trong filter_widget.dart
selectedColor: Colors.orange.withOpacity(0.3)  // Thay đổi màu chọn

// Trong search_results_with_filters_screen.dart
// Tag colors: Colors.blue -> Colors.green
```

---

## ⚡ Performance

### Tối ưu hóa
1. **StreamBuilder caching** - Dữ liệu được cache bởi Firestore
2. **Where filter** - Lọc client-side (nhanh cho dataset nhỏ)
3. **GridView.builder** - Hiển thị lazy loading

### Nếu dataset quá lớn
- Sử dụng Firestore query filters thay vì client-side filtering
- Implement pagination
- Thêm debounce cho search input

---

## 🐛 Debug

### Xem dữ liệu filter hiện tại
```dart
print('Current filter: $_currentFilter');
print('Difficulties: ${_currentFilter.selectedDifficulty}');
print('Categories: ${_currentFilter.selectedCategories}');
print('Tags: ${_currentFilter.selectedTags}');
```

### Xem danh sách tag
```dart
print('Available tags: $_availableTags');
print('Selected tag: $_selectedTagFilter');
```

---

## 📚 Tham khảo thêm

- Xem `FEATURES_GUIDE.md` cho hướng dẫn sử dụng người dùng
- Xem `filter_model.dart` cho chi tiết model
- Xem `search_results_with_filters_screen.dart` cho chi tiết giao diện

---

**Được tạo bởi**: GitHub Copilot
**Ngày**: April 23, 2026
**Phiên bản**: 1.0
