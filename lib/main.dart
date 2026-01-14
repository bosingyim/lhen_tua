import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // เรียกหน้าเมนูรวม

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Party Box',
      home: GameMenuScreen(), // <--- เริ่มต้นที่หน้าเลือกเกม
    );
  }
}