import 'package:app/booking_app/screens/doctor_home_screen.dart';
import 'package:app/booking_app/screens/home_shell.dart';
import 'package:app/booking_app/screens/public_page.dart';
import 'package:app/features/auth/data/models/user_models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'booking_app/screens/login_page.dart';
import 'features/auth/providers/auth_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Healthcare Booking',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff0284C7)),
          scaffoldBackgroundColor: const Color(0xffF5FAFD),
        ),
        home: const AppRoot(),
      ),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});
  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _checking = true;
  bool _isLoggedIn = false;
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.tryAutoLogin();
    if (mounted) {
      setState(() {
        _isLoggedIn = ok;
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xff0284C7)),
        ),
      );
    }
    if (_isLoggedIn) {
      final auth = context.watch<AuthProvider>();
      if (auth.currentUser?.role == UserRole.doctor) {
        return const DoctorHomeScreen();
      }
      return const HomeShell();
    }
    // Chưa đăng nhập -> Hiện Public Page uy tín
    return const PublicPage();
  }
}
