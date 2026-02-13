import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_user_provider.dart';
import '../../models/user_model.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<AdminUserProvider>(context, listen: false)
          .fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminUserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý người dùng"),
      ),
      body: adminProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : adminProvider.users.isEmpty
              ? const Center(child: Text("Chưa có người dùng"))
              : ListView.builder(
                  itemCount: adminProvider.users.length,
                  itemBuilder: (context, index) {
                    final UserModel user =
                        adminProvider.users[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.avatarUrl != null
                              ? NetworkImage(user.avatarUrl!)
                              : null,
                          child: user.avatarUrl == null
                              ? Text(user.name.isNotEmpty
                                  ? user.name[0]
                                  : "?")
                              : null,
                        ),
                        title: Text(user.name),
                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text("Email: ${user.email}"),
                            Text("Role: ${user.role.name}"),
                            if (user.isLocked)
                              const Text(
                                "Tài khoản đang bị khóa",
                                style: TextStyle(
                                    color: Colors.red),
                              ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == "lock") {
                              await adminProvider
                                  .toggleLockUser(user);
                            } else if (value == "role") {
                              await adminProvider
                                  .changeUserRole(user);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: "lock",
                              child: Text(
                                user.isLocked
                                    ? "Mở khóa"
                                    : "Khóa tài khoản",
                              ),
                            ),
                            const PopupMenuItem(
                              value: "role",
                              child: Text("Đổi vai trò"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
