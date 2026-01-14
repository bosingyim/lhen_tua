import 'package:flutter/material.dart';
import 'package:lhen_tua/common_widgets.dart';

class GenericPassingPhase extends StatefulWidget {
  final String playerName;      // ชื่อคนเล่น (เอาไว้เช็คเพื่อรีเซ็ตหน้าจอ)
  final String topLabel;        // ข้อความหัวข้อ เช่น "บทบาทของคุณ", "สถานที่", "คำใบ้"
  final String secretContent;   // เนื้อหาความลับ เช่น "Spy", "โรงเรียน", "Apple"
  final VoidCallback onNext;    // ฟังก์ชันไปคนต่อไป

  const GenericPassingPhase({
    required this.playerName,
    required this.topLabel,
    required this.secretContent,
    required this.onNext,
  });

  @override
  _GenericPassingPhaseState createState() => _GenericPassingPhaseState();
}

class _GenericPassingPhaseState extends State<GenericPassingPhase> with SingleTickerProviderStateMixin {
  bool isRevealed = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this, duration: Duration(milliseconds: 1500)
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // 🔥 Logic รีเซ็ตหน้าจอเมื่อเปลี่ยนคน
  @override
  void didUpdateWidget(GenericPassingPhase oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.playerName != oldWidget.playerName) {
      setState(() => isRevealed = false);
    }
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
          Text(
            widget.playerName,
            style: TextStyle(
              fontSize: 48, fontWeight: FontWeight.w900, color: Colors.transparent,
              shadows: [Shadow(offset: Offset(0, -5), color: Colors.white)],
              decoration: TextDecoration.underline, decorationColor: Colors.cyanAccent,
            ),
          ),
          SizedBox(height: 50),

          // กล่องแตะดูคำ
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
                    blurRadius: 30, spreadRadius: 5,
                  )
                ],
              ),
              child: isRevealed ? _buildRevealedContent() : _buildHiddenContent(),
            ),
          ),
          SizedBox(height: 50),

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

  Widget _buildRevealedContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // แสดงหัวข้อที่รับเข้ามา (Generic)
        Text(widget.topLabel, style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 2)),
        SizedBox(height: 20),
        // แสดงเนื้อหาความลับที่รับเข้ามา (Generic)
        Text(
          widget.secretContent,
          style: TextStyle(fontSize: 42, color: Colors.black87, fontWeight: FontWeight.w900),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Text("ห้ามให้เพื่อนเห็นนะ!", style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic)),
      ],
    );
  }
}