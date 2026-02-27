import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        title: const Text("Quản lý người dùng"),
        backgroundColor: const Color(0xff6A5AE0),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("users").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final data = users[index];

              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                margin: const EdgeInsets.only(bottom: 15),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(data['name'][0]),
                  ),
                  title: Text(data['name']),
                  subtitle: Text(data['email']),
                  trailing: Switch(
                    value: data['active'] ?? true,
                    onChanged: (value) {
                      FirebaseFirestore.instance
                          .collection("users")
                          .doc(data.id)
                          .update({"active": value});
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}