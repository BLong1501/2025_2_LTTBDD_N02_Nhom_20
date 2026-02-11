import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _user;        // Dữ liệu User hiện tại (null = chưa đăng nhập)
  bool _isLoading = false; // Trạng thái đang tải

  // Getter
  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  // 1. Hàm Đăng ký
  Future<String> register(String email, String password, String name, String username) async {
    _setLoading(true);
    
    // Lưu ý: Đảm bảo bên AuthService hàm register cũng nhận tham số kiểu này
    String? result = await _authService.register(
      email: email, 
      password: password, 
      name: name,
      username: username 
    );

    _setLoading(false);

    if (result == "Success") {
      return "Success";
    }
    return result ?? "Lỗi không xác định";
  }

  // 2. Hàm Đăng nhập
  Future<String> login(String loginInput, String password) async {
    _setLoading(true);

    // Gọi service
    var result = await _authService.login(loginInput, password);

    _setLoading(false);

    // Kiểm tra kết quả trả về
    if (result is UserModel) {
      _user = result; // Lưu user vào provider
      notifyListeners();
      return "Success";
    } else {
      // Nếu thất bại, result sẽ là chuỗi thông báo lỗi
      return result.toString();
    }
  }

  // 3. Hàm Quên mật khẩu
  Future<String> forgotPassword(String email) async {
    _setLoading(true);
    String result = await _authService.resetPassword(email);
    _setLoading(false);
    return result;
  }

  // 4. Hàm Đăng xuất (Bạn đang thiếu hàm này)
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  // --- HÀM BẠN ĐANG THIẾU Ở ĐÂY ---
  // Hàm này giúp cập nhật biến _isLoading và báo cho UI biết để quay vòng tròn
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}