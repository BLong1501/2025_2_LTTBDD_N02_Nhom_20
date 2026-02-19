import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers cho các TextFields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isFetching = true; // Trạng thái đang tải dữ liệu cũ
  bool _isLoading = false; // Trạng thái đang lưu dữ liệu

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Hàm tải dữ liệu cũ từ Firestore
  Future<void> _loadCurrentData() async {
    if (currentUser == null) return;

    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(currentUser!.uid).get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          // Ưu tiên lấy fullName từ Firestore, nếu không có thì lấy displayName của Auth
          _nameController.text = data['fullName'] ?? data['name'] ?? currentUser?.displayName ?? '';
          _bioController.text = data['bio'] ?? '';
          _phoneController.text = data['phone'] ?? '';
        });
      } else {
        // Nếu user chưa có document trong collection 'users'
        setState(() {
          _nameController.text = currentUser?.displayName ?? '';
        });
      }
    } catch (e) {
      print("Lỗi load dữ liệu user: $e");
    } finally {
      setState(() {
        _isFetching = false;
      });
    }
  }

  // Hàm lưu thông tin mới
  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tên hiển thị không được để trống!")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (currentUser != null) {
        // 1. Cập nhật Tên hiển thị trong FirebaseAuth (để load nhanh ở mọi nơi)
        await currentUser!.updateDisplayName(_nameController.text.trim());
        await currentUser!.reload();

        // 2. Cập nhật vào Collection 'users' trên Firestore
        await _firestore.collection('users').doc(currentUser!.uid).set({
          'fullName': _nameController.text.trim(),
          'bio': _bioController.text.trim(),
          'phone': _phoneController.text.trim(),
          // Không cập nhật email ở đây vì email liên quan đến Auth bảo mật
        }, SetOptions(merge: true)); // merge: true giúp không làm mất các dữ liệu khác (như avatarUrl)

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cập nhật thông tin thành công!")));
          // Trả về true để màn hình trước biết là có cập nhật và tự reload dữ liệu
          Navigator.pop(context, true); 
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi cập nhật: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Chỉnh sửa thông tin", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form Tên
                  const Text("Tên hiển thị (*)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _nameController,
                    hint: "VD: Đầu bếp Cooky",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),

                  // Form Tiểu sử
                  const Text("Tiểu sử ngắn (Bio)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _bioController,
                    hint: "VD: Yêu bếp, nghiện nhà...",
                    icon: Icons.info_outline,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  // Form Số điện thoại
                  const Text("Số điện thoại", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _phoneController,
                    hint: "VD: 0987654321",
                    icon: Icons.phone_android,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 10),
                  Text(
                    "Email không thể thay đổi ở đây để đảm bảo bảo mật tài khoản.",
                    style: TextStyle(fontSize: 12, color: Colors.grey[500], fontStyle: FontStyle.italic),
                  ),

                  const SizedBox(height: 40),

                  // Nút Lưu
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "LƯU THAY ĐỔI",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Widget hỗ trợ vẽ TextField
  Widget _buildTextField({
    required TextEditingController controller,
    String? hint,
    IconData? icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: icon != null ? Icon(icon, color: Colors.orange) : null,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.deepOrange, width: 1.5)),
        alignLabelWithHint: maxLines > 1, // Đẩy icon lên trên cùng nếu là ô nhập nhiều dòng
      ),
    );
  }
}