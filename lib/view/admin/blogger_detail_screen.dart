import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../providers/admin_user_provider.dart';
import 'package:provider/provider.dart';

class BloggerDetailScreen extends StatelessWidget {
  final UserModel user;

  const BloggerDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminUserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết Blogger",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder(
        future: provider.getBloggerStats(user.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = snapshot.data as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Username: ${user.username}",
                    style: const TextStyle(fontSize: 18)),
                Text("Email: ${user.email}"),
                Text("SĐT: ${user.phoneNumber}"),
                const SizedBox(height: 20),

                Text("Số công thức: ${stats['totalFoods']}"),
                Text("Số followers: ${stats['totalFollowers']}"),

                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red),
                  onPressed: () {
                    provider.deleteUser(user.id);
                    Navigator.pop(context);
                  },
                  child: const Text("Xóa tài khoản"),
                  ),
                Expanded(
                  child: FutureBuilder(
                    future: provider.getBloggerFoods(user.id),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final foods = snapshot.data as List;

                      return ListView.builder(
                        itemCount: foods.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(foods[index]['title']),
                          );
                        },
                      );
                    },
                  ),
                )
              ],
              
            ),
          );
        },
      ),
    );
  }
  
}