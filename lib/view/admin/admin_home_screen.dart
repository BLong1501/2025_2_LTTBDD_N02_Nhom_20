import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../services/admin_dashboard_service.dart';
import '../models/dashboard_model.dart';
import 'manage_users_screen.dart';
import 'manage_foods_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
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
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: dashboard.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// =========================
                  /// 1️⃣ HEADER SUMMARY
                  /// =========================
                  _buildHeader(dashboard.model),

                  const SizedBox(height: 20),

                  /// =========================
                  /// 2️⃣ STATISTIC CARDS
                  /// =========================
                  _buildStatisticCards(dashboard.model),

                  const SizedBox(height: 30),

                  /// =========================
                  /// 3️⃣ CHART
                  /// =========================
                  _buildChartSection(dashboard.model),

                  const SizedBox(height: 30),

                  /// =========================
                  /// 4️⃣ QUICK ACTIONS
                  /// =========================
                  _buildQuickActions(),
                ],
              ),
            ),
    );
  }

  /// ======================================================
  /// HEADER
  /// ======================================================
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

  /// ======================================================
  /// STATISTIC CARDS
  /// ======================================================
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

  /// ======================================================
  /// CHART
  /// ======================================================
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
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const months = [
                        "Jan","Feb","Mar","Apr",
                        "May","Jun","Jul","Aug",
                        "Sep","Oct","Nov","Dec"
                      ];
                      return Text(months[value.toInt()]);
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: const [
            _Legend(color: Colors.orange, text: "Pending"),
            SizedBox(width: 20),
            _Legend(color: Colors.purple, text: "Approved"),
          ],
        )
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

  /// ======================================================
  /// QUICK ACTIONS
  /// ======================================================
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _actionCard(
                icon: Icons.person,
                title: "Quản lý người dùng",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ManageUsersScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionCard(
                icon: Icons.restaurant_menu,
                title: "Quản lý công thức",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ManageFoodsScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionCard(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
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
          children: [
            Icon(icon, size: 32, color: Colors.deepPurple),
            const SizedBox(height: 10),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }
}

/// ======================================================
/// LEGEND WIDGET
/// ======================================================
class _Legend extends StatelessWidget {
  final Color color;
  final String text;

  const _Legend({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }
}