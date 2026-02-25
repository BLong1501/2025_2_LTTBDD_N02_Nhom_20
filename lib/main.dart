import 'package:btl_ltdd/view/auth/login_screen.dart';
import 'package:btl_ltdd/view/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. MỚI THÊM: Import thư viện

import 'firebase_options.dart';
import 'providers/user_provider.dart'; 
import 'providers/admin_food_provider.dart';
import 'providers/admin_stats_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. MỚI THÊM: Khởi tạo dữ liệu đa ngôn ngữ trước khi chạy App
  await EasyLocalization.ensureInitialized();
  
  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. MỚI THÊM: Bọc MyApp bằng EasyLocalization
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('vi'), Locale('en')], // Các ngôn ngữ bạn muốn hỗ trợ
      path: 'assets/langs', // Đường dẫn thư mục chứa 2 file vi.json và en.json
      fallbackLocale: const Locale('vi'), // Ngôn ngữ mặc định nếu máy người dùng dùng tiếng khác
      child: const MyApp(),
    ),
  );
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
        // 4. MỚI THÊM: Cấu hình để MaterialApp nhận diện ngôn ngữ
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale, 
        
        debugShowCheckedModeBanner: false,
        title: 'Food Blog App',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          useMaterial3: true,
        ),
        // Trỏ home về màn hình LoginScreen
        home: const LoginScreen(), 
      ),
    );
  }
}