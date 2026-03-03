import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_user_provider.dart';
import '../../models/user_model.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() =>
      _ManageUsersScreenState();
}

class _ManageUsersScreenState
    extends State<ManageUsersScreen> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<AdminUserProvider>().fetchUsers());
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<AdminUserProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Quản lý người dùng"),
        backgroundColor: Colors.deepPurple,
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.users.length,
              itemBuilder: (context, index) {
                final user =
                    provider.users[index];

                return _buildUserCard(
                    provider, user);
              },
            ),
    );
  }

  Widget _buildUserCard(
      AdminUserProvider provider,
      UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [

          /// AVATAR
          CircleAvatar(
            radius: 25,
            backgroundImage: user.avatarUrl != null
                ? NetworkImage(user.avatarUrl!)
                : null,
            backgroundColor: Colors.deepPurple,
            child: user.avatarUrl == null
                ? const Icon(Icons.person,
                    color: Colors.white)
                : null,
          ),

          const SizedBox(width: 16),

          /// INFO
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(user.email),
                Text(
                  user.role == UserRole.admin
                      ? "Admin"
                      : "Blogger",
                  style: TextStyle(
                    color:
                        user.role == UserRole.admin
                            ? Colors.red
                            : Colors.blue,
                  ),
                ),
                if (user.isLocked)
                  const Text(
                    "Tài khoản bị khóa",
                    style: TextStyle(
                        color: Colors.orange),
                  ),
              ],
            ),
          ),

          /// LOCK BUTTON
          IconButton(
            icon: Icon(
              user.isLocked
                  ? Icons.lock
                  : Icons.lock_open,
              color: Colors.orange,
            ),
            onPressed: () {
              provider.toggleLockUser(user);
            },
          ),

          /// CHANGE ROLE BUTTON
          IconButton(
            icon: const Icon(
              Icons.admin_panel_settings,
              color: Colors.blue,
            ),
            onPressed: () {
              provider.changeUserRole(user);
            },
          ),
        ],
      ),
    );
  }
}