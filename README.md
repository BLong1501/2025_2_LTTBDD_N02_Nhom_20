# 🍲 Ứng dụng Blog Ẩm Thực (Food Blog App)

Dự án cuối kỳ môn Lập trình thiết bị di động (BTL_LTDD). Ứng dụng cho phép người dùng quản lý công thức nấu ăn, chia sẻ với cộng đồng và cho phép Admin quản lý hệ thống.

---

## Tính năng chính

###  Cho người dùng (User)
* **Khám phá:** Xem các công thức món ăn mẫu và các bài chia sẻ từ cộng đồng.
* **Cá nhân hóa:** Tạo, chỉnh sửa và ghi chú công thức nấu ăn cá nhân.
* **Chia sẻ:** Đăng tải blog món ăn (bao gồm hình ảnh, nguyên liệu, quy trình) lên bảng tin chung.
* **Tìm kiếm thông minh:** Tìm kiếm món ăn theo **tên** hoặc theo **từ khóa nguyên liệu**.
* **Tương tác:** Like, để lại bình luận và lưu các món ăn yêu thích của người khác.

###  Cho quản trị viên (Admin)
* **Quản lý người dùng:** Tạo tài khoản mới, khóa/mở khóa tài khoản.
* **Quản lý nội dung:** Kiểm duyệt hoặc xóa các bài đăng vi phạm.

---

##  Cấu trúc thư mục (Project Structure)

Dự án tuân thủ kiến trúc phân lớp để dễ dàng bảo trì:

* `lib/core/`: Các cấu hình chung (Theme, Constants, Widgets dùng chung).
* `lib/data/`: Tầng dữ liệu (Models, Repositories để kết nối API/Firebase).
* `lib/providers/`: Quản lý trạng thái (State Management) tập trung.
* `lib/modules/`: Chứa giao diện người dùng chia theo từng tính năng (Auth, Home, Recipe, Admin...).
* `lib/services/`: Các dịch vụ bổ trợ (Upload ảnh, Notifications).

---

## Công nghệ sử dụng

* **Framework:** Flutter
* **Language:** Dart
* **State Management:** Provider
* **Storage:** (Dự kiến: SQLite hoặc Firebase)

---

##  Hướng dẫn cài đặt

1.  Clone project về máy.
2.  Chạy lệnh lấy dependencies:
    ```bash
    flutter pub get
    ```
3.  Chạy ứng dụng:
    ```bash
    flutter run
    ```

---
**Đội ngũ phát triển:** [Tên của bạn]