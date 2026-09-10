import 'package:flutter/material.dart';

class AdminDoctors extends StatelessWidget {
  const AdminDoctors({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Quản lý bác sĩ',
          style: TextStyle(fontSize: 25),
        ),
      ),
    );
  }
}