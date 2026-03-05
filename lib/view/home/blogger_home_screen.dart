import 'package:btl_ltdd/view/community/community_screen.dart';
import 'package:btl_ltdd/view/home/meal_plan_screen.dart';
import 'package:btl_ltdd/view/profile/profile_screen.dart';
import 'package:btl_ltdd/view/widgets/blogger_navigator_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/food_model.dart'; 
import '../food/meal_plan_detail_screen.dart';

// --- HÀM HỖ TRỢ DÙNG CHUNG: Bỏ dấu tiếng Việt để tìm kiếm thông minh ---
String removeVietnameseTones(String str) {
  str = str.toLowerCase();
  str = str.replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a');
  str = str.replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e');
  str = str.replaceAll(RegExp(r'[ìíịỉĩ]'), 'i');
  str = str.replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o');
  str = str.replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u');
  str = str.replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y');
  str = str.replaceAll(RegExp(r'[đ]'), 'd');
  return str;
}

// --- MÀN HÌNH GỐC CHỨA THANH ĐIỀU HƯỚNG ---
class BloggerHomeScreen extends StatefulWidget {
  const BloggerHomeScreen({super.key});

  @override
  State<BloggerHomeScreen> createState() => _BloggerHomeScreenState();
}

class _BloggerHomeScreenState extends State<BloggerHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DiscoverView(), // Tab 1: Khám phá
    const CommunityScreen(), // Tab 2: Cộng đồng
    const MealPlansScreen(), // Tab 3: Thực đơn
    const ProfileScreen(), // Tab 4: Cá nhân
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(
          key: ValueKey(currentLocale.languageCode),
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

// --- MÀN HÌNH DISCOVER (MẶC ĐỊNH CHỈ HIỆN BÀI ADMIN & SUGGESTIONS) ---
class DiscoverView extends StatefulWidget {
  const DiscoverView({super.key});

  @override
  State<DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<DiscoverView> {
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  // Hàm chuyển sang trang Kết quả tìm kiếm
  void _goToSearchResults(String keyword) {
    if (keyword.trim().isEmpty) return;
    
    // Đóng bàn phím
    FocusScope.of(context).unfocus();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SearchResultsScreen(keyword: keyword.trim())),
    ).then((_) {
      // Khi từ trang tìm kiếm Back về -> Reset lại ô tìm kiếm
      _searchController.clear();
      setState(() {
        _searchQuery = "";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. THANH TÌM KIẾM
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                child: const Icon(Icons.rice_bowl, color: Colors.white),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Material( 
                  color: Colors.grey[200], 
                  borderRadius: BorderRadius.circular(30), 
                  child: SizedBox(
                    height: 45,
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search, // Hiện nút Tìm/Kính lúp trên bàn phím
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value; 
                        });
                      },
                      onSubmitted: (value) {
                        // Khi ấn Enter/Tìm kiếm trên bàn phím
                        _goToSearchResults(value);
                      },
                      style: const TextStyle(color: Colors.black), 
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        hintText: "Tìm tên món, nguyên liệu...",
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        // Nút X để xóa nhanh chữ
                        suffixIcon: _searchQuery.isNotEmpty 
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = "");
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 2. NẾU KHÔNG TÌM KIẾM -> HIỆN BANNER VÀ CÔNG THỨC ADMIN
          if (_searchQuery.trim().isEmpty) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF005D6F), Color(0xFF007991)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child:  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("wellcome_to".tr(), style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  Text("COOKY!", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, fontFamily: 'Cursive')),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: Text("what_meal_plan".tr(), style: TextStyle(color: Colors.white, fontSize: 16))),
                      Icon(Icons.auto_awesome, color: Colors.amberAccent),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 25),
            
            // CHỈ HIỆN BÀI CỦA ADMIN (isFeatured)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('foods').where('isFeatured', isEqualTo: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.orange));
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("Admin chưa thêm công thức nào.", style: TextStyle(color: Colors.grey)));

                final foodsDocs = snapshot.data!.docs;
                return GridView.builder(
                  shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 15, mainAxisSpacing: 20),
                  itemCount: foodsDocs.length,
                  itemBuilder: (context, index) => _buildFoodCard(context, foodsDocs[index]),
                );
              },
            ),
          ] 
          // 3. NẾU ĐANG GÕ CHỮ -> HIỆN DANH SÁCH SUGGESTION (GỢI Ý)
          else ...[
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('foods').where('isApproved', isEqualTo: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator());
                  
                  final searchKeyword = removeVietnameseTones(_searchQuery.trim());
                  List<DocumentSnapshot> suggestions = [];

                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final food = FoodModel.fromMap(data, doc.id);
                    if (food.isFeatured || food.isShared) {
                      final titleNoTones = removeVietnameseTones(food.title);
                      final ingredientsNoTones = removeVietnameseTones(food.ingredients.join(" "));
                      if (titleNoTones.contains(searchKeyword) || ingredientsNoTones.contains(searchKeyword)) {
                        suggestions.add(doc);
                      }
                    }
                  }

                  return ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // Dòng mặc định: Tìm tất cả cho "..."
                      ListTile(
                        leading: const Icon(Icons.search, color: Colors.orange),
                        title: Text('${'search_for'.tr()} "$_searchQuery"', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                        onTap: () => _goToSearchResults(_searchQuery),
                      ),
                      const Divider(height: 1),
                      
                      // Hiện tối đa 5 kết quả gợi ý
                      ...suggestions.take(5).map((doc) {
                        final food = FoodModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(food.imageUrl, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.fastfood)),
                          ),
                          title: Text(food.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text("🔥 ${'level'.tr()}: ${food.difficulty}", style: const TextStyle(fontSize: 12)),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MealDetailScreen(food: food))),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildFoodCard(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final food = FoodModel.fromMap(data, doc.id);
    double averageRating = (data['rating'] ?? 0.0).toDouble();
    String ratingDisplay = averageRating > 0 ? "$averageRating/5" : "0/5";

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MealDetailScreen(food: food))),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, spreadRadius: 2)]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: food.imageUrl.isNotEmpty ? Image.network(food.imageUrl, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Center(child: Icon(Icons.broken_image, color: Colors.grey))) : const Center(child: Icon(Icons.fastfood, color: Colors.orange, size: 40)),
                      ),
                    ),
                    if (food.isFeatured)
                      Positioned(top: 10, right: 10, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle), child: const Icon(Icons.star, color: Colors.white, size: 12))),
                    if (food.difficulty.isNotEmpty)
                      Positioned(top: 10, left: 10, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)), child: Text(food.difficulty, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${food.time} • ⭐ $ratingDisplay", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(food.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =======================================================================
// --- TRANG HIỂN THỊ KẾT QUẢ TÌM KIẾM (TÌM CẢ BÀI ADMIN & CỘNG ĐỒNG) ---
// =======================================================================
class SearchResultsScreen extends StatelessWidget {
  final String keyword;

  const SearchResultsScreen({super.key, required this.keyword});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Kết quả cho "$keyword"', style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('foods').where('isApproved', isEqualTo: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.orange));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("Chưa có công thức nào."));

          final searchKeyword = removeVietnameseTones(keyword);
          List<DocumentSnapshot> filteredFoods = [];

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final food = FoodModel.fromMap(data, doc.id);
            
            // Tìm trong cả bài Admin và bài chia sẻ
            if (food.isFeatured || food.isShared) {
              final titleNoTones = removeVietnameseTones(food.title);
              final ingredientsNoTones = removeVietnameseTones(food.ingredients.join(" "));

              if (titleNoTones.contains(searchKeyword) || ingredientsNoTones.contains(searchKeyword)) {
                filteredFoods.add(doc);
              }
            }
          }

          if (filteredFoods.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 15),
                  Text("no_results".tr(), style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 15, mainAxisSpacing: 20),
            itemCount: filteredFoods.length,
            itemBuilder: (context, index) {
              // Tái sử dụng lại cách vẽ thẻ (card)
              final doc = filteredFoods[index];
              final data = doc.data() as Map<String, dynamic>;
              final food = FoodModel.fromMap(data, doc.id);
              double averageRating = (data['rating'] ?? 0.0).toDouble();

              return InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MealDetailScreen(food: food))),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, spreadRadius: 2)]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
                              child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), child: food.imageUrl.isNotEmpty ? Image.network(food.imageUrl, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Center(child: Icon(Icons.broken_image, color: Colors.grey))) : const Center(child: Icon(Icons.fastfood, color: Colors.orange, size: 40))),
                            ),
                            if (food.isFeatured) Positioned(top: 10, right: 10, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle), child: const Icon(Icons.star, color: Colors.white, size: 12))),
                            if (food.difficulty.isNotEmpty) Positioned(top: 10, left: 10, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)), child: Text(food.difficulty, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${food.time} • ⭐ ${averageRating > 0 ? averageRating : "0/5"}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(food.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}