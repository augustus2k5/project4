import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import 'screens/admin/admin_dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [], // Để trống danh sách provider tạm thời
      child: const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('App đang phát triển'),
          ),
        ),
      ),
    );
  }
}
