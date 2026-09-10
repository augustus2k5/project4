import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'booking_app/screens/login_page.dart';
void main(){runApp(const BookingApp());}
class BookingApp extends StatelessWidget{const BookingApp({super.key});@override Widget build(BuildContext context)=>ChangeNotifierProvider(create:(_)=>AuthProvider(),child:MaterialApp(debugShowCheckedModeBanner:false,title:'HealthCare Booking',theme:ThemeData(useMaterial3:true,fontFamily:'Arial',colorScheme:ColorScheme.fromSeed(seedColor:const Color(0xff0284C7)),scaffoldBackgroundColor:const Color(0xffF5FAFD)),home:const BookingLoginPage()));}
