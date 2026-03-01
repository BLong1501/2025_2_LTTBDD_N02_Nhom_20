import 'package:btl_ltdd/view/food/meal_plan_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/food_model.dart';
// import '../food/meal_detail_screen.dart';

class PublicProfileScreen extends StatefulWidget {
  final String authorId; // ID của người chủ trang profile này

  const PublicProfileScreen({super.key, required this.authorId});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  
  bool _isFollowing = false;
  int _followersCount = 0;
  Map<String, dynamic>? _userData;
  bool _isLoadingInfo = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // Tải thông tin của Blogger này
  Future<void> _loadUserInfo() async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(widget.authorId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Kiểm tra xem mình đã follow người này chưa
        List<dynamic> followers = data['followers'] ?? [];
        
        setState(() {
          _userData = data;
          _followersCount = followers.length;
          _isFollowing = followers.contains(_currentUserId);
          _isLoadingInfo = false;
        });
      }
    } catch (e) {
      print("Lỗi load Public Profile: $e");
      setState(() => _isLoadingInfo = false);
    }
  }

  // Hàm xử lý Follow / Unfollow
  Future<void> _toggleFollow() async {
    if (_currentUserId.isEmpty) return;

    setState(() {
      _isFollowing = !_isFollowing;
      _followersCount += _isFollowing ? 1 : -1; // Cập nhật UI ngay lập tức cho mượt
    });

    try {
      final docRef = _firestore.collection('users').doc(widget.authorId);
      
      if (_isFollowing) {
        // Thêm ID mình vào mảng followers của họ
        await docRef.update({
          'followers': FieldValue.arrayUnion([_currentUserId])
        });
      } else {
        // Xóa ID mình khỏi mảng followers của họ
        await docRef.update({
          'followers': FieldValue.arrayRemove([_currentUserId])
        });
      }
    } catch (e) {
      // Nếu lỗi, hoàn tác lại UI
      setState(() {
        _isFollowing = !_isFollowing;
        _followersCount += _isFollowing ? 1 : -1;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_userData?['fullName'] ?? _userData?['name'] ?? "Trang cá nhân", style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoadingInfo 
          ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
          : Column(
              children: [
                // --- 1. HEADER (Thông tin Blogger) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.orange.shade100,
                        backgroundImage: (_userData?['avatarUrl'] != null && _userData!['avatarUrl'].toString().isNotEmpty)
                            ? NetworkImage(_userData!['avatarUrl'])
                            : null,
                        child: (_userData?['avatarUrl'] == null || _userData!['avatarUrl'].toString().isEmpty)
                            ? const Icon(Icons.person, size: 40, color: Colors.deepOrange)
                            : null,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userData?['fullName'] ?? _userData?['name'] ?? "Đầu bếp Cooky",
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "${_followersCount} Người theo dõi",
                                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 10),
                                
                                // --- LẤY LẠI UID NGAY TẠI ĐÂY ---
                                Builder(
                                  builder: (context) {
                                    String realCurrentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
                                    
                                    // BẠN CÓ THỂ MỞ COMMENT DÒNG DƯỚI ĐỂ CHECK LOG XEM 2 ID CÓ THẬT SỰ TRÙNG NHAU KHÔNG
                                    // print("Author ID: ${widget.authorId} | My ID: $realCurrentUserId");

                                    // NẾU KHÁC NHAU THÌ MỚI HIỆN NÚT FOLLOW
                                    if (widget.authorId != realCurrentUserId) {
                                      return SizedBox(
                                        width: double.infinity,
                                        height: 35,
                                        child: ElevatedButton(
                                          onPressed: _toggleFollow,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _isFollowing ? Colors.grey[200] : Colors.deepOrange,
                                            foregroundColor: _isFollowing ? Colors.black87 : Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          child: Text(
                                            _isFollowing ? "Đang theo dõi" : "Theo dõi",
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      );
                                    } else {
                                      // NẾU LÀ CHÍNH MÌNH -> ẨN NÚT
                                      return const SizedBox.shrink(); 
                                    }
                                  }
                                ),
                                // --------------------------------
                              ],
                            ),
                          )
                    ],
                  ),
                ),
                
                if (_userData?['bio'] != null && _userData!['bio'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(_userData!['bio'], style: const TextStyle(fontSize: 15)),
                    ),
                  ),

                const Divider(thickness: 1, color: Color(0xFFF0F0F0)),

                // --- 2. GRID CÔNG THỨC CỦA TÁC GIẢ ---
                const Padding(
                  padding: EdgeInsets.all(15),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Công thức đã chia sẻ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),

                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    // Lấy các bài đăng của user này & được đánh dấu isShared = true
                    stream: _firestore.collection('foods')
                        .where('authorId', isEqualTo: widget.authorId)
                        .where('isShared', isEqualTo: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return const Center(
                          child: Text("Người dùng này chưa chia sẻ công thức nào.", style: TextStyle(color: Colors.grey)),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // 2 cột
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.85, // Tỉ lệ chiều cao/rộng của ô
                        ),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          // Chuyển Data về FoodModel
                          final docData = docs[index].data() as Map<String, dynamic>;
                          final food = FoodModel.fromMap(docData, docs[index].id);

                          return InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => MealDetailScreen(food: food)));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.grey[300], // Thêm nền xám phòng khi không có ảnh
                                
                                // --- SỬA Ở ĐÂY: Kiểm tra có ảnh mới dùng NetworkImage ---
                                image: food.imageUrl.isNotEmpty 
                                    ? DecorationImage(
                                        image: NetworkImage(food.imageUrl),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                                    stops: const [0.5, 1.0],
                                  ),
                                ),
                                alignment: Alignment.bottomLeft,
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  food.title,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}