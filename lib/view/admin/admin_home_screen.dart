import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../auth/login_screen.dart';
import 'manage_users_screen.dart';
import 'manage_foods_screen.dart';
import 'admin_stats_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<UserProvider>(context, listen: false).logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.admin_panel_settings, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            Text("Xin chào Admin, ${user?.name}!", 
                 style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Quản lý người dùng và bài viết tại đây."),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              icon: const Icon(Icons.people),
              label: const Text("Quản lý người dùng"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageUsersScreen(),
                  ),
                );
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.restaurant),
              label: const Text("Quản lý công thức"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const ManageFoodsScreen(),
                  ),
                );
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.bar_chart),
              label: const Text("Xem thống kê"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AdminStatsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}