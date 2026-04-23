import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/filter_model.dart';

class FilterBottomSheet extends StatefulWidget {
  final FilterModel initialFilter;
  final Function(FilterModel) onFilterChanged;

  const FilterBottomSheet({
    super.key,
    required this.initialFilter,
    required this.onFilterChanged,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late FilterModel _filter;

  final List<String> difficultyOptions = ['Dễ', 'Trung bình', 'Khó'];
  final List<String> categoryOptions = ['Món chính', 'Món phụ', 'Tráng miệng', 'Nước uống', 'Khai vị'];

  @override
  void initState() {
    super.initState();
    _filter = FilterModel(
      selectedDifficulty: List.from(widget.initialFilter.selectedDifficulty),
      selectedCategories: List.from(widget.initialFilter.selectedCategories),
      selectedTags: List.from(widget.initialFilter.selectedTags),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'filters'.tr(),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (_filter.hasActiveFilters())
                    GestureDetector(
                      onTap: () {
                        setState(() => _filter.clearFilters());
                        Navigator.pop(context);
                        widget.onFilterChanged(_filter);
                      },
                      child: Text(
                        'clear_all'.tr(),
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Lọc theo mức độ khó
                  _buildSectionTitle('Difficulty Level'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: difficultyOptions.map((difficulty) {
                      final isSelected = _filter.selectedDifficulty.contains(difficulty);
                      return FilterChip(
                        label: Text(difficulty),
                        selected: isSelected,
                        backgroundColor: Colors.grey[100],
                        selectedColor: Colors.orange.withOpacity(0.3),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.orange : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _filter.selectedDifficulty.add(difficulty);
                            } else {
                              _filter.selectedDifficulty.remove(difficulty);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // 2. Lọc theo loại món ăn (Chính/Phụ)
                  _buildSectionTitle('Food Category'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categoryOptions.map((category) {
                      final isSelected = _filter.selectedCategories.contains(category);
                      return FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        backgroundColor: Colors.grey[100],
                        selectedColor: Colors.blue.withOpacity(0.3),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.blue : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _filter.selectedCategories.add(category);
                            } else {
                              _filter.selectedCategories.remove(category);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),

                  // 3. Nút Áp dụng
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onFilterChanged(_filter);
                      },
                      child: Text(
                        'apply_filters'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

// --- FILTER CHIP BUTTON ĐỘC LẬP ---
class CustomFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;

  const CustomFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedColor = Colors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor.withOpacity(0.2) : Colors.grey[100],
          border: Border.all(
            color: isSelected ? selectedColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? selectedColor : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
