# 🎯 Hướng dẫn sử dụng tính năng Tìm kiếm & Lọc nâng cao

## 📋 Tổng quan

Đã thêm các tính năng mới vào phần tìm kiếm của ứng dụng COOKY:

### ✨ Tính năng mới:
1. **Lọc theo mức độ khó** (Dễ, Trung bình, Khó)
2. **Lọc theo loại món ăn** (Món chính, Món phụ, Tráng miệng, Nước uống, Khai vị)
3. **Tìm kiếm theo Tag** - Chọn tag để lọc kết quả

---

## 📁 Các file đã tạo/cập nhật

### File mới tạo:
- **`lib/models/filter_model.dart`** - Model để lưu trữ trạng thái bộ lọc
- **`lib/view/widgets/filter_widget.dart`** - Widget hiển thị các tùy chọn lọc
- **`lib/view/food/search_results_with_filters_screen.dart`** - Màn hình tìm kiếm nâng cao với lọc

### File đã cập nhật:
- **`lib/view/home/blogger_home_screen.dart`** - Sử dụng màn hình tìm kiếm mới
- **`assets/langs/en.json`** - Thêm các key dịch cho tiếng Anh
- **`assets/langs/vi.json`** - Thêm các key dịch cho tiếng Việt

---

## 🎮 Cách sử dụng

### 1. **Tìm kiếm theo tên & nguyên liệu** (cũ)
- Nhập từ khóa vào thanh tìm kiếm
- Ấn Enter hoặc nút Tìm trên bàn phím
- Kết quả sẽ hiển thị các món ăn khớp

### 2. **Lọc theo mức độ khó** (MỚI)
- Ở màn hình kết quả tìm kiếm, nhấn nút **Filters** (góc phải)
- Chọn một hoặc nhiều mức độ: Dễ / Trung bình / Khó
- Ấn **Apply Filters** để áp dụng

### 3. **Lọc theo loại món ăn** (MỚI)
- Ở màn hình kết quả tìm kiếm, nhấn nút **Filters**
- Chọn loại món: Món chính / Món phụ / Tráng miệng / Nước uống / Khai vị
- Có thể chọn nhiều loại cùng một lúc
- Ấn **Apply Filters**

### 4. **Tìm kiếm theo Tag** (MỚI)
- Ở màn hình kết quả tìm kiếm, bạn sẽ thấy thanh Tag ngay dưới AppBar
- Danh sách tất cả tag có sẵn sẽ hiển thị
- Nhấn vào một tag để lọc kết quả
- Nhấn "Tất cả" (All) để xóa lọc tag

### 5. **Xóa tất cả bộ lọc**
- Ở màn hình kết quả tìm kiếm, nhấn nút **Filters**
- Ở phía trên cùng của popup, nhấn **Clear all** để xóa tất cả bộ lọc

---

## 🛠️ Tích hợp vào dự án

Các file đã được tạo sẵn, bạn chỉ cần:

1. Đảm bảo các trường dữ liệu trong Firestore:
   - `difficulty`: Mức độ khó (Dễ, Trung bình, Khó)
   - `category`: Loại món ăn (Món chính, Món phụ, ...)
   - `tags`: Danh sách tag (List<String>)

2. Khởi động lại ứng dụng để tải localization mới

3. Thử chức năng tìm kiếm với lọc

---

## 📝 Cấu trúc dữ liệu Firestore

Các trường cần có trong collection `foods`:

```json
{
  "title": "Gà nướng thơm",
  "difficulty": "Dễ",
  "category": "Món chính",
  "tags": ["nướng", "gà", "cay"],
  "ingredients": [...],
  "imageUrl": "...",
  "isApproved": true,
  "isFeatured": false,
  "isShared": true,
  "rating": 4.5,
  ...
}
```

---

## 🎨 Giao diện

### Thanh Filter Button:
- **Cam (Orange)** - Khi có bộ lọc đang hoạt động
- **Xám (Gray)** - Khi không có bộ lọc nào

### Thanh Tag:
- Hiển thị tất cả tag có sẵn
- Tag được chọn sẽ có nền xanh dương

### Hiển thị bộ lọc hoạt động:
- Hiển thị ở phía trên danh sách kết quả
- Dễ nhìn thấy những bộ lọc đang được áp dụng

---

## 🔄 Tương thích ngược

- SearchResultsScreen cũ vẫn được giữ lại (comment out) để tương thích
- Có thể xóa nó nếu không cần dùng

---

## 💡 Tùy chỉnh

### Thêm mức độ khó mới:
```dart
// Trong filter_widget.dart
final List<String> difficultyOptions = ['Dễ', 'Trung bình', 'Khó', 'Rất khó'];
```

### Thêm loại món ăn mới:
```dart
// Trong filter_widget.dart
final List<String> categoryOptions = ['Món chính', 'Món phụ', 'Tráng miệng', 'Nước uống', 'Khai vị', 'Cơm'];
```

### Thay đổi màu sắc:
- Lọc mức độ: Cam (Colors.orange)
- Lọc loại món: Xanh dương (Colors.blue)
- Tag: Xanh lá (Colors.green)

---

## 🐛 Troubleshooting

**Vấn đề**: Tag không hiển thị
- Kiểm tra xem dữ liệu Firestore có trường `tags` không
- Kiểm tra xem `isApproved: true` trong dữ liệu

**Vấn đề**: Bộ lọc không hoạt động
- Kiểm tra xem `category` và `difficulty` đã được điền đúng không

**Vấn đề**: Không thấy kết quả tìm kiếm
- Đảm bảo `isApproved: true` hoặc `isShared: true`

---

## 📱 Hỗ trợ đa ngôn ngữ

Tất cả tên nút và thông báo đã được thêm vào file dịch:
- **en.json** - Tiếng Anh
- **vi.json** - Tiếng Việt

---

**Được tạo bởi**: GitHub Copilot
**Ngày**: April 23, 2026
