import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // 1. เพิ่ม import นี้
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lhen Tua เล่นตัว เดอะ ปาตี้',
      // 2. เพิ่มส่วน theme ตรงนี้
      theme: ThemeData(
        brightness: Brightness.dark, // คุมโทนเข้ม
        textTheme: GoogleFonts.kanitTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: GameMenuScreen(),
    );
  }
}