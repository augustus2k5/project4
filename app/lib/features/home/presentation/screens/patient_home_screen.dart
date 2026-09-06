import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _PatientHomeScreen();
}

class _PatientHomeScreen extends State<PatientHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Đây là trang Patient', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
