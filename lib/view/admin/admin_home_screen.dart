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
  String _selectedStatistic = "users";

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
                      content:
                          const Text("Hiện chưa có thông báo mới."),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context),
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
                  builder: (_) => const LoginScreen(),
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
        selectedItemColor: Colors.deepPurple,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
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

  /// ================= DASHBOARD =================
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
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
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
            style:
                const TextStyle(color: Colors.white),
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
      physics:
          const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _statCard("Total Users",
            model?.totalUsers ?? 0,
            Icons.people,
            Colors.blue),
        _statCard("Total Foods",
            model?.totalFoods ?? 0,
            Icons.restaurant,
            Colors.green),
        _statCard("Pending Approval",
            model?.pendingFoods ?? 0,
            Icons.hourglass_empty,
            Colors.orange),
        _statCard("Featured Foods",
            model?.featuredFoods ?? 0,
            Icons.star,
            Colors.purple),
      ],
    );
  }

  Widget _statCard(String title, int value,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6,
              offset: const Offset(2, 2))
        ],
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(icon,
              color: color, size: 32),
          const SizedBox(height: 10),
          Text(
            value.toString(),
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(title,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 13))
        ],
      ),
    );
  }

  /// ================= CHART =================
  Widget _buildChartSection(DashboardModel? model) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          "Thống kê hệ thống",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        /// DROPDOWN
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(12),
            border: Border.all(
                color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedStatistic,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: "users",
                  child: Text(
                      "Người dùng đăng ký"),
                ),
                DropdownMenuItem(
                  value: "recipes",
                  child: Text(
                      "Công thức được cập nhật"),
                ),
                DropdownMenuItem(
                  value: "blogger",
                  child: Text(
                      "Bài viết blogger chia sẻ"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatistic =
                      value!;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 20),

        /// CHART BOX
        Container(
          padding:
              const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 6,
              )
            ],
          ),
          child: SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                gridData:
                    FlGridData(show: true),
                borderData:
                    FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles:
                      AxisTitles(
                    sideTitles:
                        SideTitles(
                      showTitles: true,
                      getTitlesWidget:
                          (value, meta) {
                        const months = [
                          '1','2','3','4','5','6',
                          '7','8','9','10','11','12'
                        ];
                        if (value
                                .toInt() <
                            0 ||
                            value
                                    .toInt() >
                                11) {
                          return const Text('');
                        }
                        return Text(months[
                            value.toInt()]);
                      },
                    ),
                  ),
                ),
                barGroups:
                    _buildDynamicBarGroups(
                        model),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// ================= DYNAMIC BAR DATA =================
  List<BarChartGroupData>
      _buildDynamicBarGroups(
          DashboardModel? model) {

    if (model == null) {
      return List.generate(
        12,
        (index) => BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: 0,
              width: 16,
              borderRadius:
                  BorderRadius.circular(4),
            )
          ],
        ),
      );
    }

    List<int> data;

    switch (_selectedStatistic) {
      case "users":
        data = model.monthlyUsers;
        break;
      case "recipes":
        data = model.monthlyRecipes;
        break;
      case "blogger":
        data =
            model.monthlyBloggerPosts;
        break;
      default:
        data = List.filled(12, 0);
    }

    return List.generate(12, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY:
                data[index].toDouble(),
            width: 16,
            borderRadius:
                BorderRadius.circular(4),
          ),
        ],
      );
    });
  }
}