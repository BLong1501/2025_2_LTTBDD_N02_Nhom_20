import 'dart:io';
import 'package:btl_ltdd/view/profile/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  String _displayName = "Đang tải...";
  String _postCount = "0";
  bool _isLoading = true;
  bool _isUpdatingAvatar = false; // Biến trạng thái khi đang up ảnh

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    if (currentUser == null) return;
    try {
      final results = await Future.wait([
        _firestore.collection('users').doc(currentUser!.uid).get(),
        _firestore.collection('foods').where('authorId', isEqualTo: currentUser!.uid).count().get()
      ]);

      final DocumentSnapshot userDoc = results[0] as DocumentSnapshot;
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _displayName = userData['fullName'] ?? userData['name'] ?? currentUser!.email!.split('@')[0];
        });
      } else {
        setState(() => _displayName = currentUser!.email?.split('@')[0] ?? "Người dùng ẩn danh");
      }

      final AggregateQuerySnapshot postQuery = results[1] as AggregateQuerySnapshot;
      setState(() => _postCount = postQuery.count.toString());

    } catch (e) {
      print("Lỗi load data profile: $e");
      setState(() => _displayName = "Lỗi hiển thị");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- HÀM MỚI: XỬ LÝ ĐỔI ẢNH ĐẠI DIỆN ---
  Future<void> _changeAvatar() async {
    if (currentUser == null) return;

    try {
      // 1. Mở thư viện chọn 1 ảnh
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, // Nén ảnh nhẹ đi để tải nhanh
      );

      if (pickedFile == null) return; // Người dùng hủy chọn ảnh

      setState(() => _isUpdatingAvatar = true); // Bật hiệu ứng loading trên avatar

      // 2. Upload ảnh lên Firebase Storage
      String uid = currentUser!.uid;
      Reference ref = FirebaseStorage.instance.ref().child("avatars/$uid.jpg");
      UploadTask uploadTask = ref.putFile(File(pickedFile.path));
      TaskSnapshot snapshot = await uploadTask;
      
      // 3. Lấy link ảnh
      String downloadUrl = await ref.getDownloadURL();

      // 4. Cập nhật vào FirebaseAuth (Cực kỳ quan trọng để các lần đăng nhập sau vẫn có ảnh)
      await currentUser!.updatePhotoURL(downloadUrl);
      await currentUser!.reload(); // Làm mới data user tại local

      // 5. Cập nhật vào Firestore collection 'users' (Phục vụ cho tính năng Cộng đồng hiển thị ảnh tác giả)
      await _firestore.collection('users').doc(uid).set({
        'avatarUrl': downloadUrl, // Hoặc 'photoURL' tùy cách bạn thiết kế database
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cập nhật ảnh đại diện thành công!")));
      }
    } catch (e) {
      print("Lỗi up avatar: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
      }
    } finally {
      if (mounted) setState(() => _isUpdatingAvatar = false); // Tắt hiệu ứng loading
    }
  }

  void _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Đăng xuất"),
        content: const Text("Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            child: const Text("Đăng xuất", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), 
      appBar: AppBar(
        title: const Text("Trang cá nhân", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
        : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // 1. PHẦN HEADER: Thông tin Blogger
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Column(
                    children: [
                      // Avatar bọc trong GestureDetector để có thể click
                      GestureDetector(
                        onTap: _changeAvatar, // Gọi hàm đổi ảnh khi bấm vào
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.orange.shade100,
                              backgroundImage: currentUser?.photoURL != null 
                                  ? NetworkImage(currentUser!.photoURL!) 
                                  : null,
                              child: _isUpdatingAvatar 
                                  ? const CircularProgressIndicator(color: Colors.white) // Hiện quay đều khi đang up
                                  : currentUser?.photoURL == null 
                                      ? const Icon(Icons.person, size: 50, color: Colors.deepOrange) 
                                      : null,
                            ),
                            // Nút máy ảnh
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: Colors.deepOrange, shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      Text(
                        _displayName,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        currentUser?.email ?? "Chưa cập nhật email",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      
                      const SizedBox(height: 25),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn("Bài đăng", _postCount),    
                          _buildStatColumn("Người theo dõi", "0"), 
                          _buildStatColumn("Đang theo dõi", "0"),  
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // 2. PHẦN MENU CÀI ĐẶT
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 10, bottom: 10),
                        child: Text("QUẢN LÝ TÀI KHOẢN", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                      ),
                      Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          children: [
                            _buildMenuTile(
                              icon: Icons.person_outline,
                              title: "Thay đổi thông tin cá nhân",
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                              },
                            ),
                            _buildDivider(),
                            _buildMenuTile(
                              icon: Icons.lock_outline,
                              title: "Thay đổi mật khẩu",
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đang phát triển...")));
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      const Padding(
                        padding: EdgeInsets.only(left: 10, bottom: 10),
                        child: Text("NỘI DUNG & CÀI ĐẶT", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                      ),
                      Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          children: [
                            _buildMenuTile(
                              icon: Icons.favorite_border,
                              title: "Món ăn đã yêu thích",
                              iconColor: Colors.redAccent,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đang phát triển...")));
                              },
                            ),
                            _buildDivider(),
                            _buildMenuTile(
                              icon: Icons.language,
                              title: "Ngôn ngữ",
                              trailingText: "Tiếng Việt",
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đang phát triển...")));
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            foregroundColor: Colors.red,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout),
                              SizedBox(width: 8),
                              Text("Đăng xuất", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildStatColumn(String label, String count) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildMenuTile({required IconData icon, required String title, required VoidCallback onTap, Color iconColor = Colors.black54, String? trailingText}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) Text(trailingText, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          const SizedBox(width: 5),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, indent: 60, color: Color(0xFFF0F0F0));
  }
}