import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    FocusManager.instance.primaryFocus?.unfocus(); // Ẩn bàn phím

    String currentPass = _currentPasswordController.text.trim();
    String newPass = _newPasswordController.text.trim();
    String confirmPass = _confirmPasswordController.text.trim();

    // 1. Validate form cơ bản
    if (currentPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      _showMessage("Vui lòng điền đầy đủ thông tin", Colors.red);
      return;
    }
    if (newPass.length < 6) {
      _showMessage("Mật khẩu mới phải có ít nhất 6 ký tự", Colors.red);
      return;
    }
    if (newPass != confirmPass) {
      _showMessage("Mật khẩu nhập lại không khớp", Colors.red);
      return;
    }
    if (currentPass == newPass) {
      _showMessage("Mật khẩu mới phải khác mật khẩu hiện tại", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        // 2. Xác thực lại người dùng bằng Mật khẩu cũ
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPass,
        );

        await user.reauthenticateWithCredential(credential);

        // 3. Nếu xác thực thành công -> Tiến hành đổi mật khẩu mới
        await user.updatePassword(newPass);

        _showMessage("Đổi mật khẩu thành công!", Colors.green);
        
        // 4. Quay lại trang Profile sau 1 giây
        if (mounted) {
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pop(context);
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      // Bắt các lỗi cụ thể từ Firebase
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        _showMessage("Mật khẩu hiện tại không đúng", Colors.red);
      } else {
        _showMessage("Tài khoản MXH (Google/FB) không thể đổi mật khẩu ở đây.", Colors.red);
      }
    } catch (e) {
      _showMessage("Lỗi không xác định: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Đổi mật khẩu", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Để đảm bảo bảo mật, vui lòng nhập mật khẩu hiện tại của bạn trước khi tạo mật khẩu mới.",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 30),

              // --- MẬT KHẨU HIỆN TẠI ---
               Text("current_password".tr(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              _buildPasswordField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrent,
                hint: "Nhập mật khẩu hiện tại",
                onToggleVisibility: () => setState(() => _obscureCurrent = !_obscureCurrent),
              ),
              const SizedBox(height: 20),

              // --- MẬT KHẨU MỚI ---
               Text("new_password".tr(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              _buildPasswordField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                hint: "Tối thiểu 6 ký tự",
                onToggleVisibility: () => setState(() => _obscureNew = !_obscureNew),
              ),
              const SizedBox(height: 20),

              // --- NHẬP LẠI MẬT KHẨU MỚI ---
               Text("confirm_password".tr(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              _buildPasswordField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                hint: "Nhập lại mật khẩu mới",
                onToggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              
              const SizedBox(height: 50),

              // --- NÚT XÁC NHẬN ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      :  Text(
                          "password_updated".tr(),
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool obscureText,
    required String hint,
    required VoidCallback onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.orange),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: onToggleVisibility,
        ),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), 
          borderSide: const BorderSide(color: Colors.deepOrange, width: 1.5),
        ),
      ),
    );
  }
}