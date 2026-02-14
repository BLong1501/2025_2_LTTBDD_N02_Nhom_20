import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_stats_provider.dart';

class AdminStatsScreen extends StatefulWidget {
  const AdminStatsScreen({super.key});

  @override
  State<AdminStatsScreen> createState() =>
      _AdminStatsScreenState();
}

class _AdminStatsScreenState
    extends State<AdminStatsScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() =>
        Provider.of<AdminStatsProvider>(
          context,
          listen: false,
        ).fetchStats());
  }

  @override
  Widget build(BuildContext context) {

    final provider =
        Provider.of<AdminStatsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thống kê hệ thống"),
      ),

      body: provider.isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : Padding(
              padding:
                  const EdgeInsets.all(16),

              child: Column(
                children: [

                  _buildCard(
                    "Tổng số người dùng",
                    provider.totalUsers,
                    Icons.people,
                    Colors.blue,
                  ),

                  _buildCard(
                    "Tổng số công thức",
                    provider.totalFoods,
                    Icons.restaurant,
                    Colors.green,
                  ),

                  _buildCard(
                    "Chờ duyệt",
                    provider.pendingFoods,
                    Icons.pending,
                    Colors.orange,
                  ),

                ],
              ),
            ),
    );
  }

  Widget _buildCard(
      String title,
      int value,
      IconData icon,
      Color color) {

    return Card(
      margin:
          const EdgeInsets.only(bottom: 16),

      child: ListTile(

        leading:
            Icon(icon, color: color, size: 40),

        title: Text(
          title,
          style:
              const TextStyle(fontSize: 18),
        ),

        trailing: Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
