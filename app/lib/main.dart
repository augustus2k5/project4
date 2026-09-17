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
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xff0284C7),
          ),
          scaffoldBackgroundColor: const Color(0xffF5FAFD),
        ),
        home: const BookingLoginPage(),
      ),
    );
  }
}
