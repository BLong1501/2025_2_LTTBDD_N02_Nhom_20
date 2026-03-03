import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/admin_dashboard_service.dart';
import '../../models/dashboard_model.dart';
import 'manage_users_screen.dart';
import 'manage_foods_screen.dart';
import '../auth/login_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<AdminDashboardService>().loadDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<AdminDashboardService>();

    return Scaffold(
      backgroundColor: Colors.grey[100],

      /// ================= APP BAR =================
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: [

          /// Notification
          Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Thông báo"),
                content: const Text("Hiện chưa có thông báo mới."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Đóng"),
                  ),
                ],
              ),
            );
          },
        ),
        Positioned(
          right: 10,
          top: 10,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    ),
          /// Logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(), // Import màn login
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),

      /// ================= BODY =================
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(dashboard),
          const ManageUsersScreen(),
          const ManageFoodsScreen(),
        ],
      ),

      /// ================= BOTTOM NAV =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.deepPurple,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Users",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: "Công thức",
          ),
        ],
      ),
    );
  }

  /// ================= DASHBOARD CONTENT =================
  Widget _buildDashboard(AdminDashboardService dashboard) {
    if (dashboard.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(dashboard.model),
          const SizedBox(height: 20),
          _buildStatisticCards(dashboard.model),
          const SizedBox(height: 30),
          _buildChartSection(dashboard.model),
        ],
      ),
    );
  }

  /// ================= HEADER =================
  Widget _buildHeader(DashboardModel? model) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Tổng quan hệ thống",
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          Text(
            "Users: ${model?.totalUsers ?? 0}",
            style: const TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }

  /// ================= STAT CARDS =================
  Widget _buildStatisticCards(DashboardModel? model) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _statCard("Total Users", model?.totalUsers ?? 0,
            Icons.people, Colors.blue),
        _statCard("Total Foods", model?.totalFoods ?? 0,
            Icons.restaurant, Colors.green),
        _statCard("Pending Approval", model?.pendingFoods ?? 0,
            Icons.hourglass_empty, Colors.orange),
        _statCard("Featured Foods", model?.featuredFoods ?? 0,
            Icons.star, Colors.purple),
      ],
    );
  }

  Widget _statCard(
      String title, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6,
              offset: const Offset(2, 2))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 10),
          Text(
            value.toString(),
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13))
        ],
      ),
    );
  }

  /// ================= CHART =================
  Widget _buildChartSection(DashboardModel? model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Thống kê bài viết",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              barGroups: _buildBarGroups(model),
            ),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _buildBarGroups(DashboardModel? model) {
    final pending = model?.monthlyPending ?? [];
    final approved = model?.monthlyApproved ?? [];

    return List.generate(12, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: index < pending.length ? pending[index].toDouble() : 0,
            color: Colors.orange,
            width: 6,
          ),
          BarChartRodData(
            toY: index < approved.length ? approved[index].toDouble() : 0,
            color: Colors.purple,
            width: 6,
          ),
        ],
      );
    });
  }
}