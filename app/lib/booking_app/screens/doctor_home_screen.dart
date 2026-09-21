import 'package:flutter/material.dart';
import 'doctor_home_page.dart';        
import 'doctor_appointments_page.dart';     

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  DoctorHomeScreenState createState() => DoctorHomeScreenState();
}

class DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int index = 0;

  void goTo(int i) {
    if (mounted) setState(() => index = i);
  }

  final pages = const [
    DoctorHomePage(),          // Trang chủ bác sĩ
    DoctorAppointmentsPage(),  // Danh sách bệnh nhân đặt lịch
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xffF5FAFD),
        body: SafeArea(child: pages[index]),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: goTo,
          elevation: 4,
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xffE0F2FE),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: 'Tổng quan',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded),
              label: 'Lịch khám',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Cá nhân',
            ),
          ],
        ),
      );
}