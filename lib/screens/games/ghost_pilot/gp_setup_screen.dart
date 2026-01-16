import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../models/player.dart';
import '../../../services/game_service.dart';
import 'gp_play_screen.dart';

class GhostPilotSetupScreen extends StatefulWidget {
  @override
  _GhostPilotSetupScreenState createState() => _GhostPilotSetupScreenState();
}

class _GhostPilotSetupScreenState extends State<GhostPilotSetupScreen> with TickerProviderStateMixin {
  // --- Logic เดิม ---
  List<Player> players = [];
  final TextEditingController _nameController = TextEditingController();
  final GameService _gameService = GameService();
  
  // Animation Controllers
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _bgAnimationController; // สำหรับพื้นหลังเคลื่อนไหว

  @override
  void initState() {
    super.initState();
    // Animation 1: โลโก้ลอย
    _floatController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat(reverse: true);
    
    // Animation 2: ปุ่มเต้น
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Animation 3: พื้นหลังดาววิ่ง (Warp Speed)
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _bgAnimationController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _addPlayer() {
    if (_nameController.text.trim().isNotEmpty) {
      bool isDuplicate = players.any((p) => p.name.toLowerCase() == _nameController.text.trim().toLowerCase());
      
      if (isDuplicate) {
        _showSnackBar("ซํ้าโว้ย", Colors.orangeAccent);
        return;
      }
      
      setState(() {
        players.add(Player(name: _nameController.text.trim()));
        _nameController.clear();
      });
    }
  }

  void _startGame() async {
    if (players.length < 3) {
      _showSnackBar("เครื่องบินต้องการนักบินอย่างน้อย 3 คน! ⚠️", Colors.redAccent);
      return;
    }

    List<Player> readyPlayers = await _gameService.setupGhostPilot(players);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GhostPilotPlayScreen(players: readyPlayers),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black26,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      // Stack เพื่อซ้อนพื้นหลังกับเนื้อหา
      body: Stack(
        children: [
          // 1. พื้นหลังอวกาศ
          _buildSpaceBackground(),
          
          // 2. เอฟเฟกต์ดาววิ่ง (Warp Speed)
          _buildStarField(),

          // 3. เนื้อหาหลัก
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        _buildGlassInput(),
                        SizedBox(height: 20),
                        Expanded(child: _buildPlayerList()),
                        SizedBox(height: 20),
                        _buildLaunchButton(),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Widgets ตกแต่ง ---

  Widget _buildSpaceBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0B1026), // Dark Blue
            Color(0xFF2B32B2), // Deep Purple/Blue
            Color(0xFF1488CC), // Cyan accent
          ],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
    );
  }

  Widget _buildStarField() {
    return AnimatedBuilder(
      animation: _bgAnimationController,
      builder: (context, child) {
        return CustomPaint(
          painter: StarFieldPainter(_bgAnimationController.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatController.value * 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Colors.cyanAccent, Colors.purpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Icon(Icons.airplanemode_active, size: 60, color: Colors.white),
                ),
                Text(
                  "GHOST PILOT",
                  style: TextStyle(
                    fontFamily: 'Roboto', // หรือใช้ฟอนต์เกมถ้ามี
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 3,
                    shadows: [
                      Shadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 15),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white30),
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white10
                  ),
                  child: Text(
                    "SETUP PHASE",
                    style: TextStyle(fontSize: 12, color: Colors.white70, letterSpacing: 2),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassInput() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  cursorColor: Colors.cyanAccent,
                  decoration: InputDecoration(
                    hintText: "ชื่อเล่น...",
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    prefixIcon: Icon(Icons.person_outline, color: Colors.white60),
                  ),
                  onSubmitted: (_) => _addPlayer(),
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.cyanAccent, Colors.blueAccent]),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.4), blurRadius: 8)]
                ),
                child: IconButton(
                  icon: Icon(Icons.add, color: Colors.black87),
                  onPressed: _addPlayer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerList() {
    if (players.isEmpty) {
      return Center(
        child: Opacity(
          opacity: 0.6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.radar, size: 80, color: Colors.white24),
              SizedBox(height: 16),
              Text(
                "รอกรอกชื่อ",
                style: TextStyle(color: Colors.white60, letterSpacing: 1.5),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: players.length,
      itemBuilder: (context, index) {
        return _buildPilotCard(index);
      },
    );
  }

  Widget _buildPilotCard(int index) {
    return Dismissible(
      key: ValueKey(players[index]),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        color: Colors.red.withOpacity(0.8),
        child: Icon(Icons.eject, color: Colors.white),
      ),
      onDismissed: (direction) {
        setState(() => players.removeAt(index));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: Colors.white10,
            child: Text(
              "${index + 1}",
              style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            players[index].name,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          subtitle: Text(
            "สถานะ: พร้อมลั่น",
            style: TextStyle(color: Colors.greenAccent, fontSize: 10, letterSpacing: 1),
          ),
          trailing: Icon(Icons.drag_indicator, color: Colors.white24),
        ),
      ),
    );
  }

  Widget _buildLaunchButton() {
    bool isReady = players.length >= 3;
    
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        double scale = isReady ? 1.0 + (_pulseController.value * 0.03) : 1.0;
        
        return Transform.scale(
          scale: scale,
          child: Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: isReady
                ? LinearGradient(colors: [Color(0xFFF50057), Color(0xFFFF8A65)]) // Ready: Hot Gradient
                : LinearGradient(colors: [Colors.grey, Colors.blueGrey]), // Not Ready
              boxShadow: isReady
                ? [
                    BoxShadow(
                      color: Color(0xFFF50057).withOpacity(0.5),
                      blurRadius: 20,
                      offset: Offset(0, 5),
                    )
                  ]
                : [],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: _startGame,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(isReady ? Icons.rocket_launch : Icons.lock_clock, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      isReady ? "เริ่มเกม" : "NEED ${3 - players.length} MORE",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- Class สำหรับวาดดาวเคลื่อนที่ (Warp Speed Effect) ---
class StarFieldPainter extends CustomPainter {
  final double animationValue;
  final List<Star> stars = List.generate(100, (index) => Star());

  StarFieldPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    
    for (var star in stars) {
      // คำนวณตำแหน่ง Y ให้เลื่อนลงตาม Animation
      double y = (star.y + animationValue * star.speed * size.height) % size.height;
      
      // ปรับความโปร่งใสตามความเร็ว
      paint.color = Colors.white.withOpacity(star.opacity);
      paint.strokeWidth = star.size;
      
      // วาดดาว (เส้นสั้นๆ เหมือน Motion Blur)
      canvas.drawLine(
        Offset(star.x * size.width, y),
        Offset(star.x * size.width, y - (star.speed * 20)), 
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Class เก็บข้อมูลดาวแต่ละดวง
class Star {
  double x = Random().nextDouble();
  double y = Random().nextDouble();
  double speed = Random().nextDouble() * 0.5 + 0.1;
  double size = Random().nextDouble() * 2 + 0.5;
  double opacity = Random().nextDouble() * 0.5 + 0.1;
}