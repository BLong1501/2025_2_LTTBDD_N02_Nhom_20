import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'manage_users_screen.dart';
// import 'manage_foods_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {

  int totalUsers = 0;
  int totalFoods = 0;
  int pendingFoods = 0;
  int approvedFoods = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final users =
        await FirebaseFirestore.instance.collection("users").get();
    final foods =
        await FirebaseFirestore.instance.collection("foods").get();

    int pending = 0;
    for (var doc in foods.docs) {
      if (doc['status'] == "pending") pending++;
    }

    setState(() {
      totalUsers = users.docs.length;
      totalFoods = foods.docs.length;
      pendingFoods = pending;
      approvedFoods = totalFoods - pending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      body: Column(
        children: [

          /// HEADER
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff6A5AE0), Color(0xff8E7CFF)],
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Admin Dashboard",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 15),
                Text("Xin chào Admin 👋",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text("Hôm nay có công thức chờ duyệt",
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  /// 4 CARD
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [

                      _gradientCard(
                          "$totalUsers",
                          "Total Users",
                          [Color(0xff6A5AE0), Color(0xff8E7CFF)]),

                      _gradientCard(
                          "$totalFoods",
                          "Total Foods",
                          [Color(0xffFF9F43), Color(0xffFFBE76)]),

                      _gradientCard(
                          "$pendingFoods",
                          "Pending Approval",
                          [Color(0xffFFA502), Color(0xffFFC048)]),

                      _gradientCard(
                          "$approvedFoods",
                          "Approved",
                          [Color(0xff1DD1A1), Color(0xff10AC84)]),
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// CHART
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Thống kê bài viết",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    height: 250,
                    child: BarChart(
                      BarChartData(
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(show: false),
                        barGroups: [
                          _bar(0, 5, 3),
                          _bar(1, 8, 4),
                          _bar(2, 6, 2),
                          _bar(3, 9, 5),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _gradientCard(String value, String title, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  BarChartGroupData _bar(int x, double pending, double approved) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: pending,
          color: Colors.orange,
          width: 10,
        ),
        BarChartRodData(
          toY: approved,
          color: Colors.deepPurple,
          width: 10,
        ),
      ],
    );
  }
}