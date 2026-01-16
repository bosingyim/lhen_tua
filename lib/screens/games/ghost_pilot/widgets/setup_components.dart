import 'dart:ui';
import 'package:flutter/material.dart';

// --- ส่วนหัวชื่อเกม ---
class GhostPilotHeader extends StatelessWidget {
  final AnimationController controller;
  const GhostPilotHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, controller.value * 8),
          child: Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.cyanAccent, Colors.purpleAccent],
                ).createShader(bounds),
                child: const Icon(Icons.airplanemode_active, size: 60, color: Colors.white),
              ),
              const Text(
                "GHOST PILOT",
                style: TextStyle(
                  fontSize: 36, fontWeight: FontWeight.w900,
                  color: Colors.white, letterSpacing: 3,
                  shadows: [Shadow(color: Colors.cyanAccent, blurRadius: 15)],
                ),
              ),
              const Text("SETUP PHASE", style: TextStyle(fontSize: 12, color: Colors.white70, letterSpacing: 2)),
            ],
          ),
        );
      },
    );
  }
}

// --- ช่องกรอกชื่อแบบ Glassmorphism ---
class GlassInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;
  const GlassInput({super.key, required this.controller, required this.onAdd});

  @override
  State<GlassInput> createState() => _GlassInputState();
}

class _GlassInputState extends State<GlassInput> {
  bool _isPressed = false; // ตัวแปรคุมสถานะอนิเมชั่น

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0A111A).withOpacity(0.8), // สีพื้นหลังเข้มแบบในรูป
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 253, 253, 253).withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 2,
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.w500),
              decoration: const InputDecoration(
                hintText: "กรอกชื่อผู้เล่น...",
                hintStyle: TextStyle(color: Colors.white24, fontSize: 13, letterSpacing: 1.2),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 15),
              ),
              onSubmitted: (_) => widget.onAdd(),
            ),
          ),
          
          // --- Tactical Add Button with Animation ---
          GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: widget.onAdd,
            child: AnimatedScale(
              scale: _isPressed ? 0.92 : 1.0, // ยุบตัวลงเวลาเลื่อน
              duration: const Duration(milliseconds: 100),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _isPressed 
                      ? const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2) 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color.fromARGB(255, 255, 255, 255).withOpacity(_isPressed ? 1.0 : 0.6),
                    width: 2,
                  ),
                  // แสง Glow รอบปุ่ม
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 255, 255, 255).withOpacity(_isPressed ? 0.4 : 0.1),
                      blurRadius: _isPressed ? 15 : 5,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: Icon(
                  Icons.add, // ใช้เครื่องหมายบวกเรียบๆ แบบในรูปจะดูแพงกว่า
                  color: _isPressed ? Colors.white : const Color.fromARGB(255, 255, 255, 255),
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}