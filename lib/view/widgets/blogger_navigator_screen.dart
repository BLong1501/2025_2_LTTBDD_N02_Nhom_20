import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        backgroundColor: Colors.white, // Nền trắng
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange, // Màu cam khi chọn
        unselectedItemColor: Colors.grey, // Màu xám khi chưa chọn
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
           BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'discovery'.tr(),
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'community'.tr(),
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.calendar_today_outlined),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
                  ),
                )
              ],
            ),
            label: 'meal_plans'.tr(),
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'profile'.tr(),
          ),
        ],
      ),
    );
  }
}