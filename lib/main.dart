import 'package:btl_ltdd/view/auth/login_screen.dart';
import 'package:btl_ltdd/view/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/user_provider.dart'; 
import 'providers/admin_food_provider.dart';
import 'providers/admin_stats_provider.dart';

// import 'views/auth_screen.dart'; // Đảm bảo import đúng file View bạn vừa tạo

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Bọc cả ứng dụng trong MultiProvider
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AdminFoodProvider()),
        ChangeNotifierProvider(create: (_) => AdminStatsProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Food Blog App',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          useMaterial3: true,
        ),
        // Trỏ home về màn hình TestAuthScreen nằm trong thư mục views
        home: const LoginScreen(), 
      ),
    );
  }
}