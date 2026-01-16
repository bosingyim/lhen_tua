import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../models/player.dart';
import '../../../services/game_service.dart';
import 'gp_play_screen.dart';
import 'widgets/star_field_bg.dart';
import 'widgets/setup_components.dart'; // อย่าลืมไฟล์ Header/Input ที่เราทำไว้ก่อนหน้า
import 'widgets/player_list.dart';
import 'widgets/launch_button.dart';

class GhostPilotSetupScreen extends StatefulWidget {
  @override
  _GhostPilotSetupScreenState createState() => _GhostPilotSetupScreenState();
}

class _GhostPilotSetupScreenState extends State<GhostPilotSetupScreen> with TickerProviderStateMixin {
  List<Player> players = [];
  final TextEditingController _nameController = TextEditingController();
  final GameService _gameService = GameService();
  
  late AnimationController _floatController, _pulseController, _bgController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose(); _pulseController.dispose(); _bgController.dispose(); _nameController.dispose();
    super.dispose();
  }

  void _addPlayer() {
  String name = _nameController.text.trim();
  if (name.isNotEmpty) {
    if (players.any((p) => p.name.toLowerCase() == name.toLowerCase())) {
      // เรียกใช้ Pop-up ตรงนี้
      _showWarningDialog("ซ้ำโว้ย!"); 
      return;
    }
    setState(() {
      players.add(Player(name: name));
      _nameController.clear();
    });
  }
}

void _showWarningDialog(String message) {
  showDialog(
    context: context,
    builder: (context) => Center(
      child: BackdropFilter(
        // ทำพื้นหลังเบลอตอน Pop-up ขึ้น
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.redAccent, width: 2), // ขอบสีแดงนีออน
          ),
          title: Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 50),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: Colors.redAccent.withOpacity(0.5), blurRadius: 10)
                    ],
                  ),
                  child: Text("รับทราบ!", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          StarFieldBackground(controller: _bgController),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  GhostPilotHeader(controller: _floatController),
                  const SizedBox(height: 10),
                  GlassInput(controller: _nameController, onAdd: _addPlayer),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: players.length,
                      itemBuilder: (context, index) => PlayerList(
                        name: players[index].name, index: index,
                        onDelete: () => setState(() => players.removeAt(index)),
                      ),
                    ),
                  ),
                  LaunchButton(
                    isReady: players.length >= 3,
                    remainingPlayers: 3 - players.length,
                    pulseAnimation: _pulseController,
                    onPressed: () async {
                      if (players.length >= 3) {
                        var readyPlayers = await _gameService.setupGhostPilot(players);
                        Navigator.push(context, MaterialPageRoute(builder: (c) => GhostPilotPlayScreen(players: readyPlayers)));
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}