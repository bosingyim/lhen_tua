import 'package:flutter/material.dart';

class LaunchButton extends StatelessWidget {
  final bool isReady;
  final int remainingPlayers;
  final VoidCallback onPressed;
  final Animation<double> pulseAnimation;

  const LaunchButton({
    super.key,
    required this.isReady,
    required this.remainingPlayers,
    required this.onPressed,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        // คำนวณตำแหน่งการบินของยาน (วิ่งจากซ้ายไปขวา)
        // ใช้ pulseAnimation.value เพื่อให้สัมพันธ์กับอนิเมชั่นที่ส่งมา
        final double shipPosition = -0.5 + (pulseAnimation.value * 1.5);

        return GestureDetector(
          onTap: onPressed,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                // เปลี่ยนเป็นโทน Deep Blue / Charcoal ไม่ฉูดฉาด
                gradient: isReady
                    ? const LinearGradient(
                        colors: [Color(0xFF101820), Color(0xFF1F2833)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : LinearGradient(
                        colors: [Colors.grey.shade800, Colors.grey.shade900],
                      ),
                border: Border.all(
                  color: isReady ? Colors.blueAccent.withOpacity(0.5) : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // --- อนิเมชั่นยานบินในพื้นหลัง (Background Animation) ---
                  if (isReady)
                    Positioned(
                      left: MediaQuery.of(context).size.width * shipPosition,
                      child: Opacity(
                        opacity: 0.1, // จางมากๆ เพื่อไม่ให้ฉูดฉาด
                        child: Transform.rotate(
                          angle: 0.5, // เอียงยานเล็กน้อยให้ดูเหมือนกำลังบินขึ้น
                          child: const Icon(
                            Icons.rocket_launch_rounded,
                            color: Colors.white,
                            size: 80, // ขนาดใหญ่แต่จาง เพื่อเป็น Texture
                          ),
                        ),
                      ),
                    ),

                  // --- เนื้อหาหลัก (Foreground Content) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isReady ? Icons.auto_awesome : Icons.lock_outline,
                        color: isReady ? const Color.fromARGB(255, 243, 241, 144) : Colors.white38,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isReady ? "พร้อมแล้ว" : "ต้องการอีก $remainingPlayers คน",
                        style: TextStyle(
                          color: isReady ? Colors.white : Colors.white38,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}