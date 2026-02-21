import 'dart:io';
import 'package:btl_ltdd/view/auth/login_screen.dart';
import 'package:btl_ltdd/view/profile/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'follow_list_screen.dart'; // NHỚ IMPORT FILE NÀY

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  bool _isUpdatingAvatar = false;

  // --- HÀM XỬ LÝ ĐỔI ẢNH ĐẠI DIỆN ---
  Future<void> _changeAvatar() async {
    if (currentUser == null) return;

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (pickedFile == null) return; 

      setState(() => _isUpdatingAvatar = true); 

      String uid = currentUser!.uid;
      Reference ref = FirebaseStorage.instance.ref().child("avatars/$uid.jpg");
      UploadTask uploadTask = ref.putFile(File(pickedFile.path));
      TaskSnapshot snapshot = await uploadTask;
      
      String downloadUrl = await ref.getDownloadURL();

      await currentUser!.updatePhotoURL(downloadUrl);
      await currentUser!.reload(); 

      await _firestore.collection('users').doc(uid).set({
        'avatarUrl': downloadUrl, 
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
      if (mounted) setState(() => _isUpdatingAvatar = false); 
    }
  }

  // --- HÀM ĐĂNG XUẤT ---
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
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (Route<dynamic> route) => false, 
                );
              }
            },
            child: const Text("Đăng xuất", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) return const Center(child: Text("Vui lòng đăng nhập"));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), 
      appBar: AppBar(
        title: const Text("Trang cá nhân", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      
      // SỬ DỤNG STREAM BUILDER ĐỂ LẮNG NGHE DỮ LIỆU USER REAL-TIME
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('users').doc(currentUser!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Không tìm thấy dữ liệu người dùng"));
          }

          // Lấy dữ liệu từ Firestore
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final String displayName = userData['fullName'] ?? userData['name'] ?? currentUser!.email!.split('@')[0];
          final String email = userData['email'] ?? currentUser!.email ?? "";
          
          // Ưu tiên lấy ảnh từ Firestore (nếu có), không thì lấy từ Auth
          final String avatarUrl = userData['avatarUrl'] ?? currentUser?.photoURL ?? "";

          // Tính số người theo dõi mình
          final List<dynamic> followersDynamic = userData['followers'] ?? [];
          final List<String> followersList = followersDynamic.map((e) => e.toString()).toList();
          final String followersCount = followersList.length.toString();

          return SingleChildScrollView(
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
                      // Avatar
                      GestureDetector(
                        onTap: _changeAvatar,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.orange.shade100,
                              backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                              child: _isUpdatingAvatar 
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : avatarUrl.isEmpty 
                                      ? const Icon(Icons.person, size: 50, color: Colors.deepOrange) 
                                      : null,
                            ),
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
                        displayName,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        email,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      
                      const SizedBox(height: 25),

                      // HÀNG CHỈ SỐ: DÙNG STREAM ĐỂ CẬP NHẬT REALTIME
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // A. BÀI ĐĂNG (Stream đếm số lượng document)
                          StreamBuilder<QuerySnapshot>(
                            stream: _firestore.collection('foods').where('authorId', isEqualTo: currentUser!.uid).snapshots(),
                            builder: (context, postSnap) {
                              String postCount = postSnap.hasData ? postSnap.data!.docs.length.toString() : "0";
                              return _buildStatColumn("Bài đăng", postCount, null);
                            },
                          ),

                          // B. NGƯỜI THEO DÕI (Lấy trực tiếp từ followersList ở trên)
                          _buildStatColumn("Người theo dõi", followersCount, () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => FollowListScreen(type: 'followers', uids: followersList)));
                          }), 

                          // C. ĐANG THEO DÕI (Stream tìm những người có chứa ID của mình trong mảng followers)
                          StreamBuilder<QuerySnapshot>(
                            stream: _firestore.collection('users').where('followers', arrayContains: currentUser!.uid).snapshots(),
                            builder: (context, followingSnap) {
                              String followingCount = followingSnap.hasData ? followingSnap.data!.docs.length.toString() : "0";
                              return _buildStatColumn("Đang theo dõi", followingCount, () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => FollowListScreen(type: 'following', currentUserId: currentUser!.uid)));
                              });
                            },
                          ),
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
          );
        }
      ),
    );
  }

  // --- CÁC WIDGET DÙNG CHUNG ---
  Widget _buildStatColumn(String label, String count, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          children: [
            Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          ],
        ),
      ),
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