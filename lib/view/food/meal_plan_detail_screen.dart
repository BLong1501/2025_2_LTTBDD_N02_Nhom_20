import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:btl_ltdd/view/food/edit_food_screen.dart'; 
import '../../models/food_model.dart';

class MealDetailScreen extends StatefulWidget {
  final FoodModel food;

  const MealDetailScreen({super.key, required this.food});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  int _currentRating = 5; 
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode(); // FocusNode để tự động bật bàn phím
  bool _isSubmitting = false;
  bool _hasRated = false;
  double _myRating = 0;

  // --- BIẾN TRẠNG THÁI TRẢ LỜI BÌNH LUẬN ---
  String? _replyingToCommentId; // ID của bình luận gốc đang được trả lời
  String? _replyingToUsername;  // Tên người đang được trả lời

  @override
  void initState() {
    super.initState();
    _checkIfUserRated();
  }

  Future<void> _checkIfUserRated() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final doc = await FirebaseFirestore.instance
        .collection('foods')
        .doc(widget.food.id)
        .collection('ratings')
        .doc(user.uid)
        .get();
        
    if (doc.exists && mounted) {
      setState(() {
        _hasRated = true;
        _myRating = (doc.data()?['rating'] ?? 0).toDouble();
      });
    }
  }

  // --- HÀM GỬI BÌNH LUẬN LÊN FIREBASE ---
  Future<void> _submitInteraction() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bạn cần đăng nhập để thao tác!")));
      return;
    }

    final commentText = _commentController.text.trim();

    if (_hasRated && commentText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập nội dung bình luận.")));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final foodRef = FirebaseFirestore.instance.collection('foods').doc(widget.food.id);

      // 1. Lưu điểm sao nếu chưa đánh giá
      if (!_hasRated) {
        await foodRef.collection('ratings').doc(currentUser.uid).set({
          'userId': currentUser.uid,
          'rating': _currentRating,
          'createdAt': FieldValue.serverTimestamp(),
        });

        final ratingsSnap = await foodRef.collection('ratings').get();
        double totalStars = 0;
        for (var rDoc in ratingsSnap.docs) {
          totalStars += (rDoc.data()['rating'] as num).toDouble();
        }
        double avgRating = totalStars / ratingsSnap.docs.length;

        await foodRef.update({'rating': avgRating}); 

        setState(() {
          _hasRated = true;
          _myRating = _currentRating.toDouble();
        });
      }

      // 2. Lưu bình luận (Có hỗ trợ Parent ID để phân cấp)
      if (commentText.isNotEmpty) {
        await foodRef.collection('comments').add({
          'userId': currentUser.uid,
          'userEmail': currentUser.email ?? 'User',
          'comment': commentText,
          'createdAt': FieldValue.serverTimestamp(),
          'parentId': _replyingToCommentId, // Nếu là trả lời thì sẽ có ID, nếu bình luận gốc thì null
          'likedBy': [],
        });
        
        _commentController.clear();
        setState(() {
          _replyingToCommentId = null;
          _replyingToUsername = null;
        });
      }

      if (mounted) {
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // --- HÀM XÓA CÔNG THỨC ---
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận xóa", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Bạn có chắc chắn muốn xóa công thức này không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await FirebaseFirestore.instance.collection('foods').doc(widget.food.id).delete();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xóa!")));
                  Navigator.pop(context);
                }
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
              }
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double imageHeight = MediaQuery.of(context).size.height * 0.4;
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final bool isAuthor = currentUserId == widget.food.authorId;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================== HEADER ==================
            Stack(
              children: [
                Container(
                  height: imageHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    image: widget.food.imageUrl.isNotEmpty
                        ? DecorationImage(image: NetworkImage(widget.food.imageUrl), fit: BoxFit.cover)
                        : null,
                  ),
                  child: widget.food.imageUrl.isEmpty ? const Center(child: Icon(Icons.fastfood, size: 50, color: Colors.orange)) : null,
                ),
                Container(
                  height: imageHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.3), Colors.transparent, Colors.black.withOpacity(0.8)],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  top: 50, left: 20,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
                    ),
                  ),
                ),
                if (isAuthor)
                  Positioned(
                    top: 50, right: 20,
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.black),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        onSelected: (value) {
                          if (value == 'edit') {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => EditFoodScreen(food: widget.food)));
                          } else if (value == 'delete') {
                            _confirmDelete(context);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, color: Colors.blue, size: 20), SizedBox(width: 10), Text("Chỉnh sửa")])),
                          const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 10), Text("Xóa bài", style: TextStyle(color: Colors.red))])),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 20, left: 20, right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.deepOrange, borderRadius: BorderRadius.circular(20)),
                        child: Text(widget.food.category.isNotEmpty ? widget.food.category : "Món ngon", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.food.title,
                        style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, height: 1.2),
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance.collection('foods').doc(widget.food.id).snapshots(),
                        builder: (context, snapshot) {
                          double avg = 0.0;
                          if (snapshot.hasData && snapshot.data!.exists) {
                             final data = snapshot.data!.data() as Map<String, dynamic>;
                             avg = (data['rating'] ?? 0.0).toDouble();
                          }
                          return Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 22),
                              const SizedBox(width: 6),
                              Text(
                                avg > 0 ? "${avg.toStringAsFixed(1)}/5" : "Chưa có đánh giá",
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          );
                        }
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ================== BODY ==================
            Container(
              transform: Matrix4.translationValues(0, -20, 0),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem(Icons.access_time_filled, widget.food.time.isNotEmpty ? widget.food.time : "15 phút", "Thời gian", Colors.orange.shade100, Colors.deepOrange),
                        _buildStatItem(Icons.people, widget.food.servings.isNotEmpty ? widget.food.servings : "2 người", "Khẩu phần", Colors.blue.shade50, Colors.blue),
                        _buildStatItem(Icons.local_fire_department, widget.food.difficulty.isNotEmpty ? widget.food.difficulty : "Dễ", "Độ khó", Colors.purple.shade50, Colors.purple),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text("Nguyên liệu", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    ListView.separated(
                      padding: EdgeInsets.zero, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.food.ingredients.length,
                      separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
                      itemBuilder: (ctx, idx) => _buildIngredientItem(widget.food.ingredients[idx]),
                    ),
                    const SizedBox(height: 30),
                    const Text("Hướng dẫn", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    _buildInstructionList(widget.food.instructions),
                    const SizedBox(height: 40),

                    // ================== BÌNH LUẬN & ĐÁNH GIÁ ==================
                    const Divider(thickness: 1, color: Colors.grey),
                    const SizedBox(height: 20),
                    const Text("Bình luận", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),

                    _buildReviewInputForm(),
                    const SizedBox(height: 25),
                    
                    _buildCommentsList(),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- FORM NHẬP BÌNH LUẬN ---
  Widget _buildReviewInputForm() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_hasRated) ...[
            const Text("Bạn chấm món này mấy sao?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () => setState(() => _currentRating = index + 1),
                  icon: Icon(index < _currentRating ? Icons.star : Icons.star_border, color: Colors.amber, size: 30),
                  padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                );
              }),
            ),
            const SizedBox(height: 15),
          ] else ...[
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text("Bạn đã đánh giá món này ${_myRating.toInt()} sao", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 15),
          ],

          // Nếu đang chọn "Trả lời", hiển thị thanh thông báo nhỏ
          if (_replyingToCommentId != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.reply, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(child: Text("Đang trả lời: $_replyingToUsername", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13))),
                  InkWell(
                    onTap: () => setState(() { _replyingToCommentId = null; _replyingToUsername = null; }),
                    child: const Icon(Icons.close, size: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),

          TextField(
            controller: _commentController,
            focusNode: _commentFocusNode, // Gắn FocusNode vào đây
            maxLines: 3,
            decoration: InputDecoration(
              hintText: _replyingToCommentId != null ? "Viết phản hồi..." : "Nhập bình luận của bạn...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              filled: true, fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: _isSubmitting ? null : _submitInteraction,
              child: _isSubmitting 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Gửi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }

  // --- XỬ LÝ LẤY VÀ HIỂN THỊ DANH SÁCH BÌNH LUẬN THEO CẤP BẬC ---
  Widget _buildCommentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('foods')
          .doc(widget.food.id)
          .collection('comments')
          .orderBy('createdAt', descending: true) // Mới nhất lên đầu
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("Chưa có bình luận nào.", style: TextStyle(color: Colors.grey)));

        final allComments = snapshot.data!.docs;
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;

        // Tách bình luận gốc (không có parentId) và các câu trả lời
        final parentComments = allComments.where((c) => (c.data() as Map<String, dynamic>)['parentId'] == null).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: parentComments.length,
          itemBuilder: (context, index) {
            final parentDoc = parentComments[index];
            
            // Tìm tất cả các Reply của bình luận này (đảo ngược để hiển thị reply cũ nhất ở trên, giống Facebook)
            final replies = allComments.where((c) => (c.data() as Map<String, dynamic>)['parentId'] == parentDoc.id).toList().reversed.toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vẽ bình luận cha
                _buildSingleCommentWidget(parentDoc, currentUserId, isReply: false, parentIdToReply: parentDoc.id),
                
                // Nếu có trả lời, vẽ chúng lùi vào trong
                if (replies.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 45.0, top: 4.0), // Lùi vào trong
                    child: Column(
                      children: replies.map((r) => _buildSingleCommentWidget(r, currentUserId, isReply: true, parentIdToReply: parentDoc.id)).toList(),
                    ),
                  ),
                const Divider(height: 30, color: Colors.transparent), // Khoảng cách giữa các cụm bình luận
              ],
            );
          },
        );
      },
    );
  }

  // --- WIDGET VẼ 1 BONG BÓNG BÌNH LUẬN (Dùng chung cho cả Cha và Con) ---
  Widget _buildSingleCommentWidget(DocumentSnapshot commentDoc, String? currentUserId, {required bool isReply, required String parentIdToReply}) {
    final data = commentDoc.data() as Map<String, dynamic>;
    final commentId = commentDoc.id;
    final userId = data['userId'] ?? '';
    final userEmail = data['userEmail'] ?? 'User';
    final commentText = data['comment'] ?? '';
    final Timestamp? timestamp = data['createdAt'] as Timestamp?;
    final dateStr = timestamp != null ? "${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}" : "Vừa xong";
    
    // Logic Like
    final List<String> likedBy = List<String>.from(data['likedBy'] ?? []);
    final bool isLikedByMe = currentUserId != null && likedBy.contains(currentUserId);
    final bool isMyComment = currentUserId == userId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar (Nếu là Reply thì avatar nhỏ hơn 1 chút)
          CircleAvatar(
            radius: isReply ? 16 : 20,
            backgroundColor: isReply ? Colors.grey.shade200 : Colors.orange.shade100, 
            child: Text(userEmail[0].toUpperCase(), style: TextStyle(color: isReply ? Colors.black54 : Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: isReply ? 12 : 14)),
          ),
          const SizedBox(width: 10),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Khung Bong Bóng Chat (Nhấn giữ để sửa/xóa)
                GestureDetector(
                  onLongPress: isMyComment ? () => _showCommentOptions(commentId, commentText) : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userEmail.split('@')[0], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                        const SizedBox(height: 4),
                        Text(commentText, style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.3)),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 6),
                
                // Thanh công cụ: Thời gian • Like (Có Icon) • Trả lời
                Row(
                  children: [
                    const SizedBox(width: 8),
                    Text(dateStr, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 15),
                    
                    // NÚT LIKE BẰNG ICON 👍
                    InkWell(
                      onTap: () => _toggleCommentLike(commentId, likedBy, currentUserId),
                      child: Row(
                        children: [
                          Icon(
                            isLikedByMe ? Icons.thumb_up : Icons.thumb_up_outlined, 
                            size: 14, 
                            color: isLikedByMe ? Colors.blue : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            likedBy.isNotEmpty ? "${likedBy.length}" : "Thích", 
                            style: TextStyle(
                              color: isLikedByMe ? Colors.blue : Colors.grey.shade600, 
                              fontSize: 12, 
                              fontWeight: isLikedByMe ? FontWeight.bold : FontWeight.w600
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    
                    // NÚT TRẢ LỜI
                    InkWell(
                      onTap: () {
                        setState(() {
                          _replyingToCommentId = parentIdToReply; // Luôn trỏ về ID của comment Cha để không bị lùi sâu quá 1 cấp
                          _replyingToUsername = userEmail.split('@')[0];
                        });
                        // Nhấn nút thì tự động gõ @username và bật bàn phím lên
                        _commentController.text = "@${userEmail.split('@')[0]} ";
                        FocusScope.of(context).requestFocus(_commentFocusNode);
                      },
                      child: Text("Trả lời", style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- LOGIC THÍCH / BỎ THÍCH BÌNH LUẬN ---
  Future<void> _toggleCommentLike(String commentId, List<String> currentLikes, String? uid) async {
    if (uid == null) return;
    final commentRef = FirebaseFirestore.instance.collection('foods').doc(widget.food.id).collection('comments').doc(commentId);
    if (currentLikes.contains(uid)) {
      await commentRef.update({'likedBy': FieldValue.arrayRemove([uid])});
    } else {
      await commentRef.update({'likedBy': FieldValue.arrayUnion([uid])});
    }
  }

  // --- MENU CHỈNH SỬA / XÓA BÌNH LUẬN ---
  void _showCommentOptions(String commentId, String currentText) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(margin: const EdgeInsets.symmetric(vertical: 10), width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text("Chỉnh sửa bình luận"),
              onTap: () {
                Navigator.pop(ctx); 
                _showEditCommentDialog(commentId, currentText); 
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Xóa bình luận", style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(ctx);
                await FirebaseFirestore.instance.collection('foods').doc(widget.food.id).collection('comments').doc(commentId).delete();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCommentDialog(String commentId, String currentText) {
    TextEditingController editController = TextEditingController(text: currentText);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Sửa bình luận", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: editController, maxLines: null,
          decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Nhập nội dung..."),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              if (editController.text.trim().isNotEmpty) {
                await FirebaseFirestore.instance.collection('foods').doc(widget.food.id).collection('comments').doc(commentId).update({
                  'comment': editController.text.trim(),
                });
                if (mounted) Navigator.pop(ctx);
              }
            },
            child: const Text("Lưu", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // CÁC HÀM XÂY DỰNG GIAO DIỆN PHỤ (THÔNG TIN MÓN ĂN) GIỮ NGUYÊN HOÀN TOÀN...
  Widget _buildStatItem(IconData icon, String value, String label, Color bgColor, Color iconColor) {
    return Container(
      width: 100, padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade100), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 20)),
          const SizedBox(height: 8), Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          const SizedBox(height: 4), Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildIngredientItem(String ingredient) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15), decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(15)),
      child: Row(children: [const Icon(Icons.circle, size: 8, color: Colors.deepOrange), const SizedBox(width: 15), Expanded(child: Text(ingredient, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87))), const Icon(Icons.check_circle_outline, color: Colors.grey, size: 18)]),
    );
  }

  Widget _buildInstructionList(String instructions) {
    List<String> steps = instructions.split('\n').where((s) => s.trim().isNotEmpty).toList();
    if (steps.isEmpty) return const Text("Chưa có hướng dẫn.", style: TextStyle(color: Colors.grey));
    return ListView.separated(
      padding: EdgeInsets.zero, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: steps.length, separatorBuilder: (ctx, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 30, height: 30, decoration: const BoxDecoration(color: Colors.deepOrange, shape: BoxShape.circle), alignment: Alignment.center, child: Text("${index + 1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          const SizedBox(width: 15), Expanded(child: Text(steps[index].trim(), style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87))),
        ],
      ),
    );
  }
}