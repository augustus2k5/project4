import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});
  @override
  State<StatefulWidget> createState() => _DoctorHomeScreen();
}

class _DoctorHomeScreen extends State<DoctorHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('ây là trang hoem doctor')));
  }
}
