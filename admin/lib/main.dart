import 'package:app/screens/admin/admin_dashboard.dart';
import 'package:app/services/token_manager.dart';
import 'package:flutter/material.dart';

import 'screens/admin/login/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final bool isLoggedIn = await TokenManager.hasToken();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Medical Admin',

      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),

      home: isLoggedIn ? const AdminDashboard() : const AdminLoginScreen(),
    );
  }
}
