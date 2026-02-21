import 'package:btl_ltdd/view/profile/public_profile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'public_profile_screen.dart'; // Import để click vào avatar chuyển trang

class FollowListScreen extends StatelessWidget {
  final String type; // 'followers' (Người theo dõi mình) hoặc 'following' (Người mình đang theo dõi)
  final List<String> uids; // Dùng khi type = followers
  final String currentUserId; // Dùng khi type = following

  const FollowListScreen({
    super.key, 
    required this.type, 
    this.uids = const [], 
    this.currentUserId = ''
  });

  // Hàm tải danh sách User từ Firebase
  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    final firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> usersList = [];

    try {
      if (type == 'following') {
        // Tìm những users mà mảng 'followers' của họ có chứa ID của mình
        final snap = await firestore.collection('users').where('followers', arrayContains: currentUserId).get();
        for (var doc in snap.docs) {
          usersList.add({"id": doc.id, ...doc.data()});
        }
      } else {
        // Followers: Lấy từng user dựa trên mảng UID có sẵn
        if (uids.isEmpty) return [];
        for (String uid in uids) {
          final doc = await firestore.collection('users').doc(uid).get();
          if (doc.exists) {
            usersList.add({"id": doc.id, ...doc.data() as Map<String, dynamic>});
          }
        }
      }
    } catch (e) {
      print("Lỗi tải danh sách: $e");
    }
    return usersList;
  }

  @override
  Widget build(BuildContext context) {
    String title = type == 'followers' ? "Người theo dõi" : "Đang theo dõi";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return Center(
              child: Text(
                type == 'followers' ? "Chưa có ai theo dõi bạn." : "Bạn chưa theo dõi ai.",
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (ctx, idx) => const Divider(height: 1, indent: 70),
            itemBuilder: (context, index) {
              final user = users[index];
              final name = user['fullName'] ?? user['name'] ?? user['email'] ?? "Người dùng ẩn danh";
              final avatarUrl = user['avatarUrl'];
              final userId = user['id'];

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.shade100,
                  backgroundImage: (avatarUrl != null && avatarUrl.toString().isNotEmpty) 
                      ? NetworkImage(avatarUrl) 
                      : null,
                  child: (avatarUrl == null || avatarUrl.toString().isEmpty) 
                      ? const Icon(Icons.person, color: Colors.deepOrange) 
                      : null,
                ),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                onTap: () {
                  // Click vào thì mở trang Public Profile của người đó
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => PublicProfileScreen(authorId: userId)
                  ));
                },
              );
            },
          );
        },
      ),
    );
  }
}