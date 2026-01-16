import 'dart:math';
import 'package:flutter/material.dart';

class StarFieldBackground extends StatefulWidget {
  final AnimationController controller;
  const StarFieldBackground({super.key, required this.controller});

  @override
  State<StarFieldBackground> createState() => _StarFieldBackgroundState();
}

class _StarFieldBackgroundState extends State<StarFieldBackground> {
  // สร้าง List ของดาวไว้ล่วงหน้าครั้งเดียว เพื่อไม่ให้ดาวเปลี่ยนตำแหน่งตอนวาดใหม่
  late List<StaticStar> _stars;

  @override
  void initState() {
    super.initState();
    _stars = List.generate(80, (index) => StaticStar());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. พื้นหลังโทนเข้มลึก (Deep Cinematic Space)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF020408), // ดำลึก
                Color(0xFF0B1220), // น้ำเงินเกือบดำ
                Color(0xFF101828), // Deep Space
              ],
            ),
          ),
        ),
        // 2. ดาวที่เคลื่อนไหวอย่างนุ่มนวล
        AnimatedBuilder(
          animation: widget.controller,
          builder: (context, child) {
            return CustomPaint(
              painter: CinematicStarPainter(
                stars: _stars,
                progress: widget.controller.value,
              ),
              size: Size.infinite,
            );
          },
        ),
      ],
    );
  }
}

class CinematicStarPainter extends CustomPainter {
  final List<StaticStar> stars;
  final double progress;

  CinematicStarPainter({required this.stars, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var star in stars) {
      // คำนวณตำแหน่ง Y ให้ดาวเคลื่อนที่ช้าๆ (ช้ากว่าเดิม 4 เท่า)
      double movingY = (star.y * size.height + (progress * star.speed * 50)) % size.height;
      double x = star.x * size.width;

      // วาดตัวดาวเป็นวงกลมฟุ้งๆ (Glow effect)
      final paint = Paint()
        ..color = Colors.white.withOpacity(star.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0); // ดาวจะนุ่มนวลขึ้น

      canvas.drawCircle(Offset(x, movingY), star.size, paint);
      
      // เพิ่มดาวดวงเล็กจิ๋วที่นิ่งสนิทเพื่อเพิ่มความลึก
      canvas.drawCircle(
        Offset(x, movingY), 
        star.size * 0.5, 
        Paint()..color = Colors.white.withOpacity(star.opacity + 0.2)
      );
    }
  }

  @override
  bool shouldRepaint(covariant CinematicStarPainter oldDelegate) => true;
}

class StaticStar {
  final double x = Random().nextDouble();
  final double y = Random().nextDouble();
  final double speed = Random().nextDouble() * 0.5 + 0.2;
  final double size = Random().nextDouble() * 1.5 + 0.3; // ดาวจุดเล็กๆ จะดูหรูกว่า
  final double opacity = Random().nextDouble() * 0.4 + 0.1;
}