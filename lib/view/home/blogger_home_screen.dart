import 'package:btl_ltdd/view/home/meal_plan_screen.dart';
import 'package:btl_ltdd/view/widgets/blogger_navigator_screen.dart';
import 'package:flutter/material.dart';
// import '../widgets/custom_bottom_nav.dart';

// import 'meal_plans_screen.dart'; // <--- Thêm dòng này
class BloggerHomeScreen extends StatefulWidget {
  const BloggerHomeScreen({super.key});

  @override
  State<BloggerHomeScreen> createState() => _BloggerHomeScreenState();
}

class _BloggerHomeScreenState extends State<BloggerHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DiscoverView(),
    const Center(child: Text("Community", style: TextStyle(color: Colors.black))),
    const MealPlansScreen(), // Default plan value
    const Center(child: Text("Profile", style: TextStyle(color: Colors.black))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 1. Đổi nền thành trắng
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

// --- MÀN HÌNH DISCOVER (LIGHT MODE) ---
class DiscoverView extends StatelessWidget {
  const DiscoverView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                  color: Colors.orange, // Đổi sang màu cam cho hợp theme sáng
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.rice_bowl, color: Colors.white),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // 2. Nền tìm kiếm màu xám nhạt
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const TextField(
                    style: TextStyle(color: Colors.black), // Chữ đen
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
            ],
          ),

          const SizedBox(height: 20),

          // 2. BANNER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF005D6F), Color(0xFF007991)], // Giữ màu xanh cổ vịt làm điểm nhấn
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "CHÀO MỪNG ĐẾN VỚI",
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                const Text(
                  "COOKY!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Cursive',
                  ),
                ),
                const SizedBox(height: 10),
                const Row(
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

          // 3. GRID MÓN ĂN
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 15,
              mainAxisSpacing: 20,
            ),
            itemCount: dummyFoods.length,
            itemBuilder: (context, index) {
              return _buildFoodCard(dummyFoods[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(Map<String, dynamic> food) {
    return Container(
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
                // Ảnh món ăn (NetworkImage có xử lý lỗi)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    image: DecorationImage(
                      image: NetworkImage(food['image']),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {
                        // Nếu lỗi ảnh thì hiện màu xám
                      },
                    ),
                  ),
                ),
                if (food['tag'] != null)
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
                        food['tag'],
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
                  "${food['time']} • ⭐ ${food['rating']}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12), // 3. Chữ màu xám đậm
                ),
                const SizedBox(height: 4),
                Text(
                  food['title'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87, // 4. Tiêu đề màu đen
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// DỮ LIỆU GIẢ (Đã thay link ảnh sống)
final List<Map<String, dynamic>> dummyFoods = [
  {
    "title": "Bánh quy Chocolate Chip",
    "image": "https://images.pexels.com/photos/230325/pexels-photo-230325.jpeg?auto=compress&cs=tinysrgb&w=600",
    "time": "20 p",
    "rating": "4.8",
    "tag": "Dễ làm"
  },
  {
    "title": "Mỳ Ý sốt kem nấm",
    "image": "https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg?auto=compress&cs=tinysrgb&w=600",
    "time": "30 p",
    "rating": "4.9",
    "tag": "Nóng hổi"
  },
  {
    "title": "Salad bơ tươi mát",
    "image": "https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=600",
    "time": "15 p",
    "rating": "4.5",
    "tag": "Healthy"
  },
  {
    "title": "Bánh Brownie sô cô la",
    "image": "https://images.pexels.com/photos/45202/brownie-dessert-cake-sweet-45202.jpeg?auto=compress&cs=tinysrgb&w=600",
    "time": "45 p",
    "rating": "5.0",
    "tag": null
  },
];