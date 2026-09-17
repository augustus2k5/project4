import 'package:flutter/material.dart';

class AdminPatients extends StatelessWidget {
  const AdminPatients({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Quản lý bệnh nhân',
          style: TextStyle(fontSize: 25),
        ),
      ),
    );
  }
}