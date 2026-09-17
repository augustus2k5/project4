import 'package:flutter/material.dart';

class AdminAppointments extends StatelessWidget {
  const AdminAppointments({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Quản lý lịch hẹn',
          style: TextStyle(fontSize: 25),
        ),
      ),
    );
  }
}