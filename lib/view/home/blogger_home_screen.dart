import 'package:btl_ltdd/view/community/community_screen.dart';
import 'package:btl_ltdd/view/home/meal_plan_screen.dart';
import 'package:btl_ltdd/view/profile/profile_screen.dart';
import 'package:btl_ltdd/view/widgets/blogger_navigator_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/food_model.dart'; 
import '../food/meal_plan_detail_screen.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(
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

// --- MÀN HÌNH DISCOVER (TAB 1 LẤY DATA TỪ FIREBASE) ---
class DiscoverView extends StatelessWidget {
  const DiscoverView({super.key});

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
                width: 40, 
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.orange, 
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.rice_bowl, color: Colors.white),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Material( 
                  color: Colors.grey[200], 
                  borderRadius: BorderRadius.circular(30), 
                  child: const SizedBox(
                    height: 45,
                    child: TextField(
                      style: TextStyle(color: Colors.black), 
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        hintText: "Tìm kiếm món ăn...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 2. BANNER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF005D6F), Color(0xFF007991)], 
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "CHÀO MỪNG ĐẾN VỚI",
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                Text(
                  "COOKY!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Cursive',
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Hôm nay bạn muốn ăn gì nào?",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    Icon(Icons.auto_awesome, color: Colors.amberAccent),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 25),

          // 3. GRID MÓN ĂN - LẤY DATA THẬT TỪ FIREBASE
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('foods')
                .where('isApproved', isEqualTo: true)
                .where('isFeatured', isEqualTo: true) 
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.orange));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text("Admin chưa thêm công thức nào.", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ),
                );
              }

              final foods = snapshot.data!.docs;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 20,
                ),
                itemCount: foods.length,
                itemBuilder: (context, index) {
                  return _buildFoodCard(context, foods[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // --- SỬA LỖI MATERIAL Ở ĐÂY ---
  Widget _buildFoodCard(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final food = FoodModel.fromMap(data, doc.id);

    double averageRating = (data['rating'] ?? 0.0).toDouble();
    String ratingDisplay = averageRating > 0 ? "$averageRating/5" : "0/5";

    // ĐÃ BỌC THÊM THẺ MATERIAL Ở NGOÀI CÙNG ĐỂ CHỐNG LỖI VĂNG APP
    return Material(
      color: Colors.transparent, // Giữ nền trong suốt
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => MealDetailScreen(food: food)));
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: food.imageUrl.isNotEmpty
                            ? Image.network(
                                food.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Center(
                                  child: Icon(Icons.broken_image, color: Colors.grey),
                                ),
                              )
                            : const Center(
                                child: Icon(Icons.fastfood, color: Colors.orange, size: 40),
                              ),
                      ),
                    ),
                    if (food.difficulty.isNotEmpty)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            food.difficulty, 
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${food.time} • ⭐ $ratingDisplay",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12), 
                    ),
                    const SizedBox(height: 4),
                    Text(
                      food.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black87, 
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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