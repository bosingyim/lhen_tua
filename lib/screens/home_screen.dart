import 'package:flutter/material.dart';
import 'games/ghost_pilot/gp_setup_screen.dart'; 

class GameMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A2980), Color(0xFF26D0CE)], 
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // หัวข้อแอป
                SizedBox(height: 20),
                Text(
                  "Lhen Tua เล่นตัว เดอะ ปาตี้",
                  style: TextStyle(
                    fontSize: 32, 
                    fontWeight: FontWeight.w900, 
                    color: Colors.white, 
                    letterSpacing: 1.2
                  ),
                ),
                Text(
                  "เลือกเกมที่จะเล่น",
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                SizedBox(height: 30),

                // รายชื่อเกม (ListView)
                Expanded(
                  child: ListView(
                    children: [
                      // --- เกมที่ 1: Ghost Pilot ---
                      _buildGameCard(
                        context,
                        title: "Ghost Pilot",
                        subtitle: "จับผิดคนเนียน อย่าให้ผีรู้พิกัด!",
                        icon: Icons.flight_takeoff,
                        color1: Color(0xFFFF512F),
                        color2: Color(0xFFDD2476),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => GhostPilotSetupScreen()), 
                          );
                        },
                      ),

                      SizedBox(height: 20),

                      // --- เกมที่ 2: Coming Soon ---
                      _buildGameCard(
                        context,
                        title: "เกมอื่นๆ",
                        subtitle: "เร็วๆ นี้...",
                        icon: Icons.theater_comedy,
                        color1: Colors.grey,
                        color2: Colors.blueGrey,
                        isLocked: true,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                // --- ส่วนของเครดิต (Credits Section) ---
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        Text(
                          "Developed by",
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                        Text(
                          "bossnhamdeang",
                          style: TextStyle(
                            color: Colors.white70, 
                            fontSize: 14, 
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget สร้างการ์ดเกม
  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color1,
    required Color color2,
    required VoidCallback onTap,
    bool isLocked = false,
  }) {
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: isLocked ? [Colors.grey.shade700, Colors.grey.shade800] : [color1, color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            if (!isLocked)
              BoxShadow(
                color: color1.withOpacity(0.5),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(icon, size: 150, color: Colors.white.withOpacity(0.1)),
            ),
            Padding(
              padding: EdgeInsets.all(25),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 30),
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isLocked)
              Positioned(
                top: 15,
                right: 15,
                child: Icon(Icons.lock, color: Colors.white38),
              ),
          ],
        ),
      ),
    );
  }
}