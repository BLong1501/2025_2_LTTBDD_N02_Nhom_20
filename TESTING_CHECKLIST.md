🧪 TESTING CHECKLIST - Tính năng Tìm kiếm & Lọc

═══════════════════════════════════════════════════════════════════

📋 PRE-TESTING

□ Kiểm tra Firestore có các trường cần thiết:
  □ difficulty
  □ category
  □ tags
  □ isApproved
  □ isFeatured
  □ isShared

□ Kiểm tra dữ liệu sample:
  □ Ít nhất 5 bài công thức với trạng thái isApproved: true
  □ Một số bài có isFeatured: true
  □ Một số bài có isShared: true
  □ Các bài có tags khác nhau

□ Khởi động lại ứng dụng sau khi thêm các file mới

═══════════════════════════════════════════════════════════════════

✅ TEST CASE 1: TÌM KIẾM CƠ BẢN (Hiện tại)

Bước:
1. Mở ứng dụng, đi đến tab "Khám phá"
2. Nhập từ khóa "gà" vào thanh tìm kiếm
3. Ấn Enter

Kỳ vọng:
□ Chuyển sang màn hình kết quả tìm kiếm
□ Hiển thị danh sách các bài liên quan đến "gà"
□ Hiển thị bộ lọc hoạt động (nếu có)
□ Hiển thị thanh tag (nếu có tag)

═══════════════════════════════════════════════════════════════════

✅ TEST CASE 2: LỌC THEO MỨC ĐỘ KHÓ

Bước:
1. Tìm kiếm một từ khóa
2. Nhấn nút "Filters" (góc phải AppBar)
3. Chọn "Dễ"
4. Ấn "Áp dụng bộ lọc"

Kỳ vọng:
□ Popup lọc đóng
□ Danh sách kết quả được lọc
□ Chỉ hiển thị những bài có difficulty: "Dễ"
□ Hiển thị thẻ "Dễ" trong phần Active Filters
□ Nút Filters có màu cam

Bước 5-8: Thử chọn nhiều mức độ (Dễ + Trung bình)
Kỳ vọng:
□ Danh sách hiển thị cả bài Dễ và bài Trung bình
□ Hiển thị 2 thẻ "Dễ" và "Trung bình" trong Active Filters

═══════════════════════════════════════════════════════════════════

✅ TEST CASE 3: LỌC THEO LOẠI MÓN ĂN

Bước:
1. Tìm kiếm một từ khóa
2. Nhấn nút "Filters"
3. Chọn "Món chính"
4. Ấn "Áp dụng bộ lọc"

Kỳ vọng:
□ Popup lọc đóng
□ Danh sách kết quả được lọc
□ Chỉ hiển thị những bài có category: "Món chính"
□ Hiển thị thẻ "Món chính" (màu xanh dương) trong Active Filters

Bước 5-8: Thử chọn nhiều loại (Món chính + Tráng miệng)
Kỳ vọng:
□ Danh sách hiển thị cả bài Món chính và bài Tráng miệng
□ Hiển thị 2 thẻ trong Active Filters

═══════════════════════════════════════════════════════════════════

✅ TEST CASE 4: LỌC THEO TAG

Bước:
1. Tìm kiếm một từ khóa
2. Quan sát thanh tag dưới AppBar
3. Nhấn vào một tag (ví dụ: "nướng")

Kỳ vọng:
□ Tag được chọn có nền xanh dương
□ Danh sách kết quả được lọc
□ Chỉ hiển thị những bài có tag "nướng"
□ Tag hiển thị trong Active Filters (màu xanh lá)

Bước 4-5: Nhấn tag khác
Kỳ vọng:
□ Tag trước đó được bỏ chọn
□ Tag mới được chọn
□ Danh sách kết quả update

Bước 6: Nhấn nút "Tất cả" (All)
Kỳ vọng:
□ Tất cả tag được bỏ chọn
□ Danh sách kết quả hiển thị tất cả (không lọc tag)

═══════════════════════════════════════════════════════════════════

✅ TEST CASE 5: KẾT HỢP CÁC BỘ LỌC

Bước:
1. Tìm kiếm từ khóa
2. Chọn tag "nướng"
3. Nhấn Filters
4. Chọn "Dễ" + "Món chính"
5. Ấn Áp dụng bộ lọc

Kỳ vọng:
□ Danh sách kết quả được lọc theo TẤT CẢ tiêu chí:
   - Chứa từ khóa tìm kiếm
   - Có tag "nướng"
   - Có difficulty "Dễ"
   - Có category "Món chính"
□ Active Filters hiển thị 3 thẻ (Dễ, Món chính, nướng)
□ Hiển thị số lượng kết quả (ít hoặc bằng 0 nếu không match)

═══════════════════════════════════════════════════════════════════

✅ TEST CASE 6: XÓA BỘ LỌC

Bước:
1. Áp dụng một số bộ lọc (theo test case 5)
2. Nhấn Filters
3. Nhấn "Xóa tất cả"

Kỳ vọng:
□ Popup lọc đóng
□ Tất cả checkbox được bỏ chọn
□ Active Filters biến mất
□ Danh sách kết quả hiển thị tất cả (chỉ lọc theo từ khóa tìm kiếm)
□ Nút Filters quay lại màu xám

═══════════════════════════════════════════════════════════════════

✅ TEST CASE 7: KHÔNG CÓ KẾT QUẢ

Bước:
1. Áp dụng các bộ lọc quá khắt khe
   (Ví dụ: tag "rất hiếm" + difficulty "Khó" + category "Khai vị")

Kỳ vọng:
□ Hiển thị icon search_off
□ Hiển thị thông báo "Không có kết quả phù hợp với bộ lọc của bạn"
□ Vẫn hiển thị Active Filters
□ Người dùng có thể thử lại với bộ lọc khác

═══════════════════════════════════════════════════════════════════

✅ TEST CASE 8: GIA DIỆN TRÊN THIẾT BỊ KHÁC NHAU

Android:
□ Layout responsive trên màn hình nhỏ
□ FilterBottomSheet hiển thị đúng
□ Scroll hoạt động mượt mà
□ Tag scroll ngang không bị cắt

iOS:
□ Tương tự Android
□ SafeArea không bị xâm phạm

Tablet:
□ Layout adaptive
□ GridView có số column thích hợp
□ Không bị stretch quá

═══════════════════════════════════════════════════════════════════

✅ TEST CASE 9: NGÔN NGỮ

Tiếng Anh:
1. Chuyển app sang tiếng Anh
2. Kiểm tra các text:
□ "Filters" - nút lọc
□ "Clear all" - xóa tất cả
□ "Apply Filters" - áp dụng
□ "Active Filters" - bộ lọc đang hoạt động
□ "Search Results" - tiêu đề
□ "All" - nút tất cả tag

Tiếng Việt:
1. Chuyển app sang tiếng Việt
2. Kiểm tra các text:
□ "Bộ lọc"
□ "Xóa tất cả"
□ "Áp dụng bộ lọc"
□ "Bộ lọc đang hoạt động"
□ "Kết quả tìm kiếm"
□ "Tất cả"

═══════════════════════════════════════════════════════════════════

✅ TEST CASE 10: PERFORMANCE

Bước:
1. Tìm kiếm một từ khóa
2. Áp dụng các bộ lọc
3. Quan sát thời gian load

Kỳ vọng:
□ Load <= 1 giây (sau lần đầu)
□ Scroll danh sách mượt mà
□ Không bị lag khi chọn filter
□ Memory usage bình thường

═══════════════════════════════════════════════════════════════════

✅ TEST CASE 11: EDGE CASES

1. Tìm kiếm với dấu:
   □ Nhập "gà nướng" (có dấu)
   □ Kỳ vọng: Tìm được cả "ga nuong" (bỏ dấu)

2. Tìm kiếm ký tự đặc biệt:
   □ Nhập "123", "$#@"
   □ Kỳ vọng: Không crash, hiển thị "Không có kết quả"

3. Tìm kiếm rỗng:
   □ Nhấn tìm mà không nhập gì
   □ Kỳ vọng: Không chuyển màn hình, hiển thị toast/snack

4. Quay lại từ màn hình kết quả:
   □ Tìm kiếm, lọc, sau đó nhấn back
   □ Kỳ vọng: Quay lại Discover, ô tìm kiếm rỗng

═══════════════════════════════════════════════════════════════════

✅ TEST CASE 12: INTEGRATION

1. Thêm bài công thức từ Firestore (Admin)
2. Chờ trang web cập nhật
3. Quay lại app, tìm kiếm
4. Kỳ vọng:
   □ Bài mới hiển thị trong kết quả (nếu match)
   □ Tag mới hiển thị trong thanh tag
   □ Có thể lọc theo bài mới

═══════════════════════════════════════════════════════════════════

🐛 KNOWN ISSUES / NOTES

- [ ] Nếu tag quá nhiều, thanh tag có thể cần scroll
- [ ] Nếu danh sách kết quả quá dài, có thể thêm pagination
- [ ] Firestore query có thể cần optimization nếu dữ liệu quá lớn

═══════════════════════════════════════════════════════════════════

✅ FINAL CHECK

Trước khi deploy:
□ Tất cả test case đã pass
□ Không có console error
□ Localization hoạt động đúng
□ Performance tốt
□ UI responsive trên các kích thước màn hình khác nhau
□ App không crash ở edge cases

═══════════════════════════════════════════════════════════════════

Được tạo bởi: GitHub Copilot
Ngày: April 23, 2026
