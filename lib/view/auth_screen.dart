import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class TestAuthScreen extends StatefulWidget {
  const TestAuthScreen({super.key});

  @override
  State<TestAuthScreen> createState() => _TestAuthScreenState();
}

class _TestAuthScreenState extends State<TestAuthScreen> {
  // Controller cho các ô nhập liệu
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController(); // MỚI: Nhập username
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  
  String _message = "Chưa có hành động"; 

  @override
  Widget build(BuildContext context) {
    // Lấy userProvider
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("TEST LOGIC AUTH (MỚI)")),
      body: SingleChildScrollView( // Thêm cuộn để không bị che khi bàn phím hiện
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 1. Hiển thị trạng thái Loading
            if (userProvider.isLoading) 
              const CircularProgressIndicator()
            else if (userProvider.user != null)
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.green[100],
                child: Column(
                  children: [
                    const Text(" ĐANG ĐĂNG NHẬP", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Tên: ${userProvider.user!.name}"),
                    Text("User: ${userProvider.user!.username}"),
                    Text("Email: ${userProvider.user!.email}"),
                  ],
                ),
              ),
            
            const SizedBox(height: 20),

            // 2. Các ô nhập liệu
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Họ Tên (Chỉ nhập khi Đăng ký)"),
            ),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: "Tên đăng nhập (Register/Login)"),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email (Register/Login/Reset Pass)"),
            ),
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Mật khẩu"),
            ),
            
            const SizedBox(height: 20),
            
            // 3. Nút Đăng ký (Cần đủ 4 thông tin)
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              onPressed: () async {
                String result = await userProvider.register(
                  _emailController.text.trim(),
                  _passController.text.trim(),
                  _nameController.text.trim(),
                  _usernameController.text.trim(), // Truyền thêm Username
                );
                
                setState(() {
                  _message = result == "Success" 
                      ? "✅ Đăng ký thành công!" 
                      : "❌ Lỗi: $result";
                });
              },
              child: const Text("ĐĂNG KÝ (Điền đủ 4 ô)"),
            ),

            const SizedBox(height: 10),

            // 4. Nút Đăng nhập (Dùng Username HOẶC Email)
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: () async {
                // Ưu tiên lấy text ở ô Username, nếu rỗng thì lấy ô Email
                String loginInput = _usernameController.text.isNotEmpty 
                    ? _usernameController.text.trim() 
                    : _emailController.text.trim();

                if (loginInput.isEmpty) {
                  setState(() => _message = "⚠️ Vui lòng nhập Username hoặc Email để đăng nhập");
                  return;
                }

                String result = await userProvider.login(
                  loginInput,
                  _passController.text.trim(),
                );
                
                setState(() {
                  _message = result == "Success" 
                      ? "✅ Đăng nhập thành công!" 
                      : "❌ Lỗi: $result";
                });
              },
              child: const Text("ĐĂNG NHẬP (Điền Username hoặc Email)"),
            ),

            const SizedBox(height: 10),

            // 5. Nút Quên mật khẩu
            TextButton(
              onPressed: () async {
                if (_emailController.text.isEmpty) {
                  setState(() => _message = "⚠️ Điền Email để lấy lại mật khẩu");
                  return;
                }
                String result = await userProvider.forgotPassword(_emailController.text.trim());
                setState(() {
                  _message = result == "Success" 
                      ? "📧 Đã gửi link đổi pass về email!" 
                      : "❌ Lỗi: $result";
                });
              }, 
              child: const Text("Quên mật khẩu? (Điền Email rồi bấm)")
            ),

            // 6. Nút Đăng xuất
            TextButton(
              onPressed: () {
                userProvider.logout();
                setState(() => _message = "Đã đăng xuất");
              }, 
              child: const Text("Đăng xuất", style: TextStyle(color: Colors.red))
            ),

            const SizedBox(height: 20),
            
            // 7. Hiển thị thông báo
            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.purple, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}