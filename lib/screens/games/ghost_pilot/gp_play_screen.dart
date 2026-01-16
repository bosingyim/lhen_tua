import 'package:flutter/material.dart';
import '../../../models/player.dart';
import '../../../services/game_service.dart'; // เรียก service ปกติ
// เรียก Widget กลางที่เราเพิ่งทำ
import '../../../widgets/game_phases/generic_passing_phase.dart';
import '../../../widgets/game_phases/generic_timer_phase.dart';

class GhostPilotPlayScreen extends StatefulWidget {
  final List<Player> players;
  GhostPilotPlayScreen({required this.players});

  @override
  _GhostPilotPlayScreenState createState() => _GhostPilotPlayScreenState();
}

class _GhostPilotPlayScreenState extends State<GhostPilotPlayScreen> {
  int currentIndex = 0;
  final GameService _gameService = GameService(); // สร้าง Service ไว้ใช้

  void _nextPlayer() {
    setState(() {
      currentIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDiscussionPhase = currentIndex >= widget.players.length;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: isDiscussionPhase
                    ? [Color(0xFF8E0E00), Color(0xFF1F1C18)]
                    : [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              ),
            ),
          ),
          
          SafeArea(
            child: isDiscussionPhase
                ? GenericTimerPhase(
                    startSeconds: 180,
                    eventInterval: 30,
                    onGetEvent: () => _gameService.getRandomEvent('ghost_pilot'),

                    // 🔥 จุดที่แก้: ส่งฟังก์ชันแบบระบุชื่อเกม 'ghost_pilot'
                    onGetQuestion: () => _gameService.getRandomQuestion('ghost_pilot'), 
                    
                    onExit: () => Navigator.pop(context),
                  )
                : GenericPassingPhase(
                    playerName: widget.players[currentIndex].name,
                    topLabel: "ดาวที่เราจะลงจอดคือออ...", 
                    secretContent: widget.players[currentIndex].secretWord!,
                    onNext: _nextPlayer,
          ),
          ),
        ],
      ),
    );
  }
}