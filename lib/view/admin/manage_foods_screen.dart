import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageFoodsScreen extends StatelessWidget {
  const ManageFoodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        title: const Text("Kiểm duyệt công thức"),
        backgroundColor: const Color(0xff6A5AE0),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("foods").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final foods = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: foods.length,
            itemBuilder: (context, index) {
              final data = foods[index];

              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                margin: const EdgeInsets.only(bottom: 15),
                child: ListTile(
                  leading: Image.network(
                    data['image'],
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                  title: Text(data['name']),
                  subtitle: Text(data['email'] ?? ""),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection("foods")
                              .doc(data.id)
                              .update({"status": "approved"});
                        },
                        child: const Text("Duyệt"),
                      ),
                      const SizedBox(width: 5),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection("foods")
                              .doc(data.id)
                              .delete();
                        },
                      )
                    ],
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