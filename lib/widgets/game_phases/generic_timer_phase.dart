import 'dart:async';
import 'dart:math'; // 1. เพิ่ม import นี้
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lhen_tua/common_widgets.dart';


class GenericTimerPhase extends StatefulWidget {
  final int startSeconds;
  final int eventInterval; // เราจะใช้ค่านี้เป็น "ค่าเฉลี่ย" ในการสุ่ม
  final Future<String> Function() onGetEvent;
  final Future<String> Function() onGetQuestion;
  final VoidCallback onExit;

  const GenericTimerPhase({
    required this.startSeconds,
    required this.eventInterval,
    required this.onGetEvent,
    required this.onGetQuestion,
    required this.onExit,
  });

  @override
  _GenericTimerPhaseState createState() => _GenericTimerPhaseState();
}

class _GenericTimerPhaseState extends State<GenericTimerPhase> {
  late int _timeLeft;
  Timer? _timer;
  String currentQuestion = "กดปุ่มเพื่อเริ่มคำถามแรก";
  
  // 2. ตัวแปรเก็บเวลาที่จะให้ Event เด้งครั้งถัดไป
  int _nextEventTime = -1; 

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.startSeconds;
    
    // 3. สุ่มเวลา Event รอบแรกทันทีที่เริ่มเกม
    _planNextEvent();
    
    _startTimer();
    _changeQuestion();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // 🔥 ฟังก์ชันคำนวณเวลา Event ครั้งถัดไป (สุ่ม!)
  void _planNextEvent() {
    // ช่วงเวลาที่จะสุ่ม (เช่น ถ้า interval=30 จะสุ่มระหว่าง 20 ถึง 40 วินาที)
    int minDelay = widget.eventInterval - 10; 
    int maxDelay = widget.eventInterval + 10;
    
    // กันไม่ให้ติดลบหรือน้อยไป
    if (minDelay < 10) minDelay = 10; 

    // สูตรสุ่มตัวเลข: min + Random(ส่วนต่าง)
    int randomDelay = minDelay + Random().nextInt(maxDelay - minDelay);
    
    // กำหนดเวลาเป้าหมาย (เวลานับถอยหลัง - เวลาที่สุ่มได้)
    _nextEventTime = _timeLeft - randomDelay;

    print("Next event in $randomDelay seconds (at $_nextEventTime)");
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;

            // 🔥 เช็คว่าถึงเวลาที่สุ่มไว้หรือยัง?
            if (_timeLeft == _nextEventTime) {
              _triggerEvent();     // แสดง Event
              _planNextEvent();    // สุ่มรอบต่อไปทันที
            }
            
          } else {
            _timer?.cancel();
            _showGameOverDialog();
          }
        });
      }
    });
  }

  // ... (ส่วน _showGameOverDialog และอื่นๆ เหมือนเดิมเป๊ะ) ...
  // เพื่อความชัวร์ ผมใส่โค้ดส่วนที่เหลือให้ครบกันงงครับ 👇

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(Icons.timer_off, color: Colors.redAccent, size: 50),
            SizedBox(height: 10),
            Text("หมดเวลาแล้ว! ⌛", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          "เกมจบแล้ว ได้เวลาจับคนร้าย!",
          style: TextStyle(color: Colors.white70, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: widget.onExit, 
                child: Text("จบเกม / กลับหน้าหลัก", style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  void _triggerEvent() async {
    String eventText = await widget.onGetEvent();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        Future.delayed(Duration(seconds: 5), () {
          if (dialogContext.mounted && Navigator.canPop(dialogContext)) {
            Navigator.pop(dialogContext);
          }
        });

        return AlertDialog(
          backgroundColor: Color(0xFF2C0000),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.notifications_active, color: Colors.yellowAccent, size: 30),
              SizedBox(width: 10),
              Text("EVENT ALERT!", style: TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("จะปิดเองใน 5 วิ หรือกดรับทราบ", style: TextStyle(color: Colors.white38, fontSize: 12)),
              SizedBox(height: 15),
              Text(
                eventText, 
                style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold), 
                textAlign: TextAlign.center
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (Navigator.canPop(dialogContext)) {
                  Navigator.pop(dialogContext);
                }
              },
              child: Text("รับทราบ! (ปิดทันที)", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  void _changeQuestion() async {
    String newQ = await widget.onGetQuestion();
    setState(() => currentQuestion = newQ);
  }

  String _formatTime(int seconds) {
    int min = seconds ~/ 60;
    int sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(30)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer, color: _timeLeft < 30 ? Colors.redAccent : Colors.white70),
                SizedBox(width: 10),
                Text(
                  _formatTime(_timeLeft),
                  style: TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold,
                    color: _timeLeft < 30 ? Colors.redAccent : Colors.white,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          GlassCard(
            child: Column(
              children: [
                Text("หัวข้อสนทนา", style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text(currentQuestion, textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 15),
                GestureDetector(
                  onTap: _changeQuestion,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(border: Border.all(color: Colors.white30), borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh, size: 16, color: Colors.white70),
                        SizedBox(width: 5),
                        Text("เปลี่ยนคำถาม", style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Spacer(),
          TextButton.icon(
            icon: Icon(Icons.exit_to_app, color: Colors.white54),
            label: Text("จบเกม / กลับหน้าหลัก", style: TextStyle(color: Colors.white54)),
            onPressed: widget.onExit,
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}