import 'package:app/features/auth/data/models/user_models.dart';
import 'package:app/features/home/presentation/screens/doctor_home_screen.dart';
import 'package:app/features/home/presentation/screens/patient_home_screen.dart';
import 'package:app/screens/admin/admin_dashboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeWrapperScreen extends StatefulWidget {
  final UserRole role;

  const HomeWrapperScreen({super.key, required this.role});
  @override
  State<StatefulWidget> createState() => _HomeWrapperScreen();
}

class _HomeWrapperScreen extends State<HomeWrapperScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.role == UserRole.patient) {
      return const PatientHomeScreen();
    } else if (widget.role == UserRole.doctor) {
      return const DoctorHomeScreen();
    } else if (widget.role == UserRole.admin) {
      return const AdminDashboard();
    } else {
      return const Scaffold(body: Center(child: Text('Lỗi không có role')));
    }
  }
}
