import 'package:flutter/material.dart';
import '../models/doctor.dart';
class DoctorCard extends StatelessWidget {
  final Doctor doctor; final VoidCallback onTap;
  const DoctorCard({super.key, required this.doctor, required this.onTap});
  @override Widget build(BuildContext context)=>Material(color:Colors.white,borderRadius:BorderRadius.circular(22),child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(22),child:Padding(padding:const EdgeInsets.all(16),child:Row(children:[
    Container(width:72,height:72,decoration:BoxDecoration(color:const Color(0xffE0F2FE),borderRadius:BorderRadius.circular(20)),child:const Icon(Icons.person_rounded,color:Color(0xff0284C7),size:42)),
    const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(doctor.name, maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:16,fontWeight:FontWeight.w800)),const SizedBox(height:4),Text(doctor.specialty,style:const TextStyle(color:Color(0xff0284C7),fontWeight:FontWeight.w600)),const SizedBox(height:8),Row(children:[const Icon(Icons.star_rounded,color:Color(0xffF59E0B),size:18),Text(' ${doctor.rating.toStringAsFixed(1)}',style:const TextStyle(fontWeight:FontWeight.w700)),const SizedBox(width:12),Text('${doctor.patients} lượt khám',style:const TextStyle(color:Color(0xff64748B),fontSize:12))])])),const Icon(Icons.chevron_right_rounded,color:Color(0xff94A3B8))
  ]))));
}
