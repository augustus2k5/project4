import 'package:flutter/material.dart';

class DoctorAppointmentsPage extends StatelessWidget {
  const DoctorAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5FAFD),
      appBar: AppBar(
        title: const Text('Danh sách Lịch khám'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff0F172A),
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Chưa có lịch khám mới',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}