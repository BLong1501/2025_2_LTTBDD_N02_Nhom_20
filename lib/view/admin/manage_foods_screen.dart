import 'package:flutter/material.dart';

class ManageFoodsScreen extends StatelessWidget {
  const ManageFoodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý công thức")),
      body: const Center(
        child: Text("Danh sách món ăn sẽ hiển thị ở đây"),
      ),
    );
  }
}