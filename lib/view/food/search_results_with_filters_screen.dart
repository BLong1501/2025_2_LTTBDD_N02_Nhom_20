import 'package:btl_ltdd/view/widgets/filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/food_model.dart';
import '../../models/filter_model.dart';
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

// =======================================================================
// --- TRANG HIỂN THỊ KẾT QUẢ TÌM KIẾM NÂNG CAO (VỚI LỌC VÀ TAG) ---
// =======================================================================
class SearchResultsWithFiltersScreen extends StatefulWidget {
  final String keyword;
  final FilterModel initialFilter;

  const SearchResultsWithFiltersScreen({
    super.key,
    required this.keyword,
    required this.initialFilter,
  });

  @override
  State<SearchResultsWithFiltersScreen> createState() =>
      _SearchResultsWithFiltersScreenState();
}

class _SearchResultsWithFiltersScreenState
    extends State<SearchResultsWithFiltersScreen> {
  late FilterModel _currentFilter;
  final TextEditingController _tagSearchController = TextEditingController();
  String _selectedTagFilter = ""; // Tag được chọn để lọc

  // Danh sách tất cả các tag có sẵn
  List<String> _availableTags = [];

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.initialFilter;
    _loadAvailableTags();
  }

  // Tải danh sách tất cả tag từ Firestore
  Future<void> _loadAvailableTags() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('foods')
        .where('isApproved', isEqualTo: true)
        .get();

    Set<String> tags = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final tagList = List<String>.from(data['tags'] ?? []);
      tags.addAll(tagList);
    }

    setState(() {
      _availableTags = tags.toList()..sort();
    });
  }

  // Hàm lọc danh sách món ăn
  List<DocumentSnapshot> _filterFoods(List<DocumentSnapshot> foods) {
    final searchKeyword = removeVietnameseTones(widget.keyword.toLowerCase());

    return foods.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final food = FoodModel.fromMap(data, doc.id);

      // 1. Lọc theo tìm kiếm (tên + nguyên liệu + tag)
      final titleNoTones = removeVietnameseTones(food.title.toLowerCase());
      final ingredientsNoTones =
          removeVietnameseTones(food.ingredients.join(" ").toLowerCase());
      final tagsNoTones = removeVietnameseTones(food.tags.join(" ").toLowerCase());

      bool matchesSearch = titleNoTones.contains(searchKeyword) ||
          ingredientsNoTones.contains(searchKeyword) ||
          tagsNoTones.contains(searchKeyword);

      if (!matchesSearch) return false;

      // 2. Lọc theo mức độ khó
      if (_currentFilter.selectedDifficulty.isNotEmpty &&
          !_currentFilter.selectedDifficulty.contains(food.difficulty)) {
        return false;
      }

      // 3. Lọc theo danh mục
      if (_currentFilter.selectedCategories.isNotEmpty &&
          !_currentFilter.selectedCategories.contains(food.category)) {
        return false;
      }

      // 4. Lọc theo tag được chọn
      if (_selectedTagFilter.isNotEmpty &&
          !food.tags.contains(_selectedTagFilter)) {
        return false;
      }

      // 5. Chỉ hiện bài Admin hoặc bài chia sẻ
      if (!food.isFeatured && !food.isShared) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'search_results'.tr(),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          // Nút Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  backgroundColor: _currentFilter.hasActiveFilters()
                      ? Colors.orange
                      : Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (BuildContext context) {
                      return FilterBottomSheet(
                        initialFilter: _currentFilter,
                        onFilterChanged: (newFilter) {
                          setState(() {
                            _currentFilter = newFilter;
                          });
                        },
                      );
                    },
                  );
                },
                icon: Icon(
                  Icons.filter_list,
                  color: _currentFilter.hasActiveFilters()
                      ? Colors.white
                      : Colors.black,
                  size: 18,
                ),
                label: Text(
                  'filters'.tr(),
                  style: TextStyle(
                    color: _currentFilter.hasActiveFilters()
                        ? Colors.white
                        : Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('foods')
            .where('isApproved', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 15),
                  Text(
                    "no_recipes".tr(),
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final filteredFoods = _filterFoods(snapshot.data!.docs);

          return SingleChildScrollView(
            child: Column(
              children: [
                // --- HIỂN THỊ THANH TÌM KIẾM TAG ---
                if (_availableTags.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey[200]!,
                        ),
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // Tag "Tất cả" để xóa lọc tag
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedTagFilter = "");
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _selectedTagFilter.isEmpty
                                      ? Colors.orange
                                      : Colors.grey[100],
                                  border: Border.all(
                                    color: _selectedTagFilter.isEmpty
                                        ? Colors.orange
                                        : Colors.grey[300]!,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'all'.tr(),
                                  style: TextStyle(
                                    color: _selectedTagFilter.isEmpty
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Danh sách các tag
                          ..._availableTags.map((tag) {
                            final isSelected = _selectedTagFilter == tag;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedTagFilter =
                                        isSelected ? "" : tag;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.blue.withOpacity(0.2)
                                        : Colors.grey[100],
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.grey[300]!,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.black,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),

                // --- HIỂN THỊ TRẠNG THÁI LỌC HIỆN TẠI ---
                if (_currentFilter.hasActiveFilters() ||
                    _selectedTagFilter.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.blue[200]!,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'active_filters'.tr(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            // Hiển thị mức độ được chọn
                            ..._currentFilter.selectedDifficulty
                                .map((d) => Chip(
                                      label: Text(d),
                                      backgroundColor:
                                          Colors.orange.withOpacity(0.2),
                                      labelStyle: const TextStyle(
                                        color: Colors.orange,
                                        fontSize: 12,
                                      ),
                                    ))
                                .toList(),
                            // Hiển thị danh mục được chọn
                            ..._currentFilter.selectedCategories
                                .map((c) => Chip(
                                      label: Text(c),
                                      backgroundColor:
                                          Colors.blue.withOpacity(0.2),
                                      labelStyle: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 12,
                                      ),
                                    ))
                                .toList(),
                            // Hiển thị tag được chọn
                            if (_selectedTagFilter.isNotEmpty)
                              Chip(
                                label: Text(_selectedTagFilter),
                                backgroundColor:
                                    Colors.green.withOpacity(0.2),
                                labelStyle: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                // --- HIỂN THỊ KẾT QUẢ ---
                if (filteredFoods.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.search_off,
                            size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 15),
                        Text(
                          'no_results_with_filters'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  GridView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: filteredFoods.length,
                    itemBuilder: (context, index) {
                      return _buildFoodCard(
                        context,
                        filteredFoods[index],
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFoodCard(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final food = FoodModel.fromMap(data, doc.id);
    double averageRating = (data['rating'] ?? 0.0).toDouble();
    String ratingDisplay = averageRating > 0 ? "$averageRating/5" : "0/5";

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MealDetailScreen(food: food)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 2,
            )
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
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12)),
                      child: food.imageUrl.isNotEmpty
                          ? Image.network(
                              food.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.broken_image,
                                    color: Colors.grey),
                              ),
                            )
                          : const Center(
                              child: Icon(Icons.fastfood,
                                  color: Colors.orange, size: 40),
                            ),
                    ),
                  ),
                  if (food.isFeatured)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.star,
                            color: Colors.white, size: 12),
                      ),
                    ),
                  if (food.difficulty.isNotEmpty)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          food.difficulty,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }

  @override
  void dispose() {
    _tagSearchController.dispose();
    super.dispose();
  }
}
