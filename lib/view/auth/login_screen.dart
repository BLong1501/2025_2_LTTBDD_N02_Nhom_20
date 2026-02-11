import 'package:btl_ltdd/providers/user_provider.dart';
import 'package:btl_ltdd/view/auth/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import thư viện lưu trữ
// import '../providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _obscureText = true; 
  bool _rememberMe = false; // Biến trạng thái cho ô checkbox

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials(); // Tự động tải mật khẩu khi mở màn hình
  }

  // HÀM 1: Tải thông tin đã lưu (nếu có)
  void _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('remember_me') ?? false;
      if (_rememberMe) {
        _usernameController.text = prefs.getString('saved_username') ?? '';
        _passController.text = prefs.getString('saved_password') ?? '';
      }
    });
  }

  // HÀM 2: Xử lý đăng nhập & Lưu mật khẩu
  void _handleLogin() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (_usernameController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập tài khoản và mật khẩu")),
      );
      return;
    }

    // Gọi hàm login từ Provider
    String result = await userProvider.login(
      _usernameController.text.trim(),
      _passController.text.trim(),
    );

    if (mounted) {
      if (result == "Success") {
        // --- XỬ LÝ LƯU MẬT KHẨU ---
        final prefs = await SharedPreferences.getInstance();
        if (_rememberMe) {
          // Nếu tích chọn -> Lưu lại
          await prefs.setBool('remember_me', true);
          await prefs.setString('saved_username', _usernameController.text.trim());
          await prefs.setString('saved_password', _passController.text.trim());
        } else {
          // Nếu bỏ tích -> Xóa đi
          await prefs.remove('remember_me');
          await prefs.remove('saved_username');
          await prefs.remove('saved_password');
        }
        // ---------------------------

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Đăng nhập thành công!")),
        );
        // Navigator.pushReplacement... (Chuyển trang Home)
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ $result"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildSocialButton({
    required String text,
    required Color color,
    required Color textColor,
    required IconData icon,
    bool hasBorder = false,
  }) {
    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: hasBorder ? const BorderSide(color: Colors.grey) : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        onPressed: () {},
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<UserProvider>(context).isLoading;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),// Ẩn bàn phím khi chạm ra ngoài
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        "COOKY!",
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Cursive',
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Đăng nhập",
                        style: TextStyle(fontSize: 20, color: Colors.black54),
                      ),
                      const SizedBox(height: 40),
      
                      // --- INPUT TÀI KHOẢN ---
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: "Tài khoản ",
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(35),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                      const SizedBox(height: 15),
      
                      // --- INPUT MẬT KHẨU ---
                      TextField(
                        controller: _passController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          labelText: "Mật khẩu",
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscureText = !_obscureText),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(35)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
      
                      // --- HÀNG CHỨA CHECKBOX & QUÊN MẬT KHẨU ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Checkbox Lưu mật khẩu
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                activeColor: Colors.lightBlue[400],
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value!;
                                  });
                                },
                              ),
                              const Text("Lưu mật khẩu"),
                            ],
                          ),
                          
                          // Nút Quên mật khẩu
                          TextButton(
                            onPressed: () {
                               Navigator.push(context,
                               MaterialPageRoute(builder:(context) => const ForgotPasswordScreen(),))      ;                    },
                            child: const Text("Quên mật khẩu?"),
                          ),
                        ],
                      ),
                      // ------------------------------------------
      
                      const SizedBox(height: 20),
      
                      // --- DÒNG PHÂN CÁCH ---
                      const Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text("hoặc đăng nhập bằng", style: TextStyle(color: Colors.grey)),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
      
                      const SizedBox(height: 20),
      
                      // --- CÁC NÚT SSO ---
                      _buildSocialButton(
                        text: "Sign in with Apple",
                        color: Colors.black,
                        textColor: Colors.white,
                        icon: Icons.apple,
                      ),
                      _buildSocialButton(
                        text: "Sign in with Facebook",
                        color: const Color(0xFF1877F2),
                        textColor: Colors.white,
                        icon: Icons.facebook,
                      ),
                      _buildSocialButton(
                        text: "Sign in with Google",
                        color: Colors.white,
                        textColor: Colors.black87,
                        icon: Icons.g_mobiledata,
                        hasBorder: true,
                      ),
                      
                      const SizedBox(height: 30),
                      const Text(
                        "Bằng cách đăng nhập, bạn đồng ý với User Agreement và Privacy Policy.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      
              // NÚT ĐĂNG NHẬP (Sticky Footer)
              InkWell(
                onTap: isLoading ? null : _handleLogin,
                child: Container(
                  width: double.infinity,
                  height: 60,
                  color: Colors.lightBlue[400],
                  alignment: Alignment.center,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "ĐĂNG NHẬP",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16)
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}