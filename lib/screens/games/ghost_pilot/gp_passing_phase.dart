import 'package:flutter/material.dart';
import '../../../common_widgets.dart';
import '../../../models/player.dart';

class PassingPhase extends StatefulWidget {
  final Player player;       // รับข้อมูลผู้เล่นคนปัจจุบัน
  final VoidCallback onNext; // ฟังก์ชันเพื่อไปคนถัดไป

  const PassingPhase({required this.player, required this.onNext});

  @override
  _PassingPhaseState createState() => _PassingPhaseState();
}

class _PassingPhaseState extends State<PassingPhase> with SingleTickerProviderStateMixin {
  bool isRevealed = false; // สถานะว่าเปิดดูคำหรือยัง
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  // 🔥 เพิ่มส่วนนี้ครับ: เพื่อเช็คว่าถ้าเปลี่ยนคนแล้ว ให้ล็อคหน้าจอเหมือนเดิม
  @override
  void didUpdateWidget(PassingPhase oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ถ้าผู้เล่นเปลี่ยนคน (ชื่อไม่เหมือนเดิม)
    if (widget.player.name != oldWidget.player.name) {
      setState(() {
        isRevealed = false; // รีเซ็ตกลับไปเป็น "ยังไม่เปิดดู"
      });
    }
  }
  // -----------------------------------------------------

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("ตาของ...", style: TextStyle(fontSize: 24, color: Colors.white)),
          SizedBox(height: 10),
          // ชื่อคนเล่น
          Text(
            widget.player.name,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.transparent,
              shadows: [Shadow(offset: Offset(0, -5), color: Colors.white)],
              decoration: TextDecoration.underline,
              decorationColor: Colors.cyanAccent,
            ),
          ),
          SizedBox(height: 50),
          
          // กล่องแตะเพื่อดูคำลับ
          GestureDetector(
            onTap: () {
              if (!isRevealed) setState(() => isRevealed = true);
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isRevealed ? Colors.white.withOpacity(0.9) : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: isRevealed ? Colors.cyanAccent.withOpacity(0.5) : Colors.black26,
                    blurRadius: 30,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: isRevealed ? _buildRevealedContent() : _buildHiddenContent(),
            ),
          ),
          SizedBox(height: 50),
          
          // ปุ่มส่งให้เพื่อน (จะโผล่มาเมื่อกดดูคำแล้ว)
          AnimatedOpacity(
            opacity: isRevealed ? 1.0 : 0.0,
            duration: Duration(milliseconds: 300),
            child: GradientButton(
              text: "จำได้แล้ว! ส่งให้เพื่อน",
              icon: Icons.send_rounded,
              colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
              onPressed: isRevealed ? widget.onNext : () {},
            ),
          ),
        ],
      ),
    );
  }

  // UI ตอนยังไม่เปิดดู
  Widget _buildHiddenContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_pulseController.value * 0.1),
              child: Icon(Icons.fingerprint, size: 80, color: Colors.white70),
            );
          },
        ),
        SizedBox(height: 20),
        Text("แตะเพื่อดูข้อมูลลับ", style: TextStyle(color: Colors.white, fontSize: 18)),
      ],
    );
  }

  // UI ตอนเปิดดูแล้ว
  Widget _buildRevealedContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("TOP SECRET", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 2)),
        SizedBox(height: 20),
        Text(
          "${widget.player.secretWord}",
          style: TextStyle(fontSize: 42, color: Colors.black87, fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 10),
        Text("ห้ามให้เพื่อนเห็นนะ!", style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic)),
      ],
    );
  }
}