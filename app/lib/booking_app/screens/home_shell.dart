import 'package:flutter/material.dart';
import 'home_page.dart';
import 'appointments_page.dart';
import 'profile_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override HomeShellState createState() => HomeShellState();
}

class HomeShellState extends State<HomeShell> {
  int index = 0;

  void goTo(int i) {
    if (mounted) setState(() => index = i);
  }

  final pages = const[BookingHomePage(), AppointmentsPage(), ProfilePage()];

  @override Widget build(BuildContext context) =>
      Scaffold(backgroundColor: const Color(0xffF5FAFD),
          body: SafeArea(child: pages[index]),
          bottomNavigationBar: NavigationBar(selectedIndex: index,
              onDestinationSelected: goTo,
              elevation: 4,
              backgroundColor: Colors.white,
              indicatorColor: const Color(0xffE0F2FE),
              destinations: const[
                NavigationDestination(icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: 'Trang chủ'),
                NavigationDestination(icon: Icon(Icons.calendar_today_outlined),
                    selectedIcon: Icon(Icons.calendar_today_rounded),
                    label: 'Lịch hẹn'),
                NavigationDestination(icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: 'Hồ sơ')
              ]));
}
