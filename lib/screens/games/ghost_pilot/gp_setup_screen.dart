import 'package:flutter/material.dart';
import '../../../models/player.dart';
import '../../../services/game_service.dart';
import 'gp_play_screen.dart'; // เรียกไฟล์หน้าเล่นเกม

class GhostPilotSetupScreen extends StatefulWidget {
  @override
  _GhostPilotSetupScreenState createState() => _GhostPilotSetupScreenState();
}

class _GhostPilotSetupScreenState extends State<GhostPilotSetupScreen> with TickerProviderStateMixin {
  List<Player> players = [];
  final TextEditingController _nameController = TextEditingController();
  final GameService _gameService = GameService();
  late AnimationController _floatController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _addPlayer() {
    if (_nameController.text.isNotEmpty) {
      bool isDuplicate = players.any((p) => p.name.toLowerCase() == _nameController.text.toLowerCase());
      
      if (isDuplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("มีชื่อนี้แล้วนะ! ใช้ชื่อเล่นอื่นสิ 😄"), backgroundColor: Colors.orange),
        );
        return;
      }
      
      setState(() {
        players.add(Player(name: _nameController.text));
        _nameController.clear();
      });
      
      if (players.length >= 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("พร้อมเริ่มเกมแล้ว! 🎮"), backgroundColor: Colors.green, duration: Duration(seconds: 1)),
        );
      }
    }
  }

  // --- จุดสำคัญ: สุ่มบทบาทตรงนี้แค่ครั้งเดียว ---
  void _startGame() async {
    if (players.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ต้องมีอย่างน้อย 3 คนนะ! 🍻"), backgroundColor: Colors.deepOrange),
      );
      return;
    }

    // เรียกฟังก์ชันสุ่มบทบาทจาก GameService
    // ข้อมูล readyPlayers ที่ได้จะนิ่งแล้ว ไม่เปลี่ยนไปมา
    List<Player> readyPlayers = await _gameService.setupGhostPilot(players);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GhostPilotPlayScreen(players: readyPlayers),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // เพิ่ม AppBar แบบใส เพื่อให้มีปุ่มกด Back กลับไปหน้าเมนู
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6A1B9A),
              Color(0xFFAB47BC),
              Color(0xFFE91E63),
              Color(0xFFFF6F00),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      _buildNameInput(),
                      SizedBox(height: 20),
                      
                      Expanded(child: _buildPlayersList()),
                      
                      SizedBox(height: 20),
                      _buildStartButton(),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatController.value * 10),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20), // ลด padding นิดหน่อย
            child: Column(
              children: [
                Text(
                  "👻 GHOST PILOT ✈️", // เปลี่ยนชื่อให้ตรงกับเกม
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                    shadows: [Shadow(color: Colors.black45, offset: Offset(3, 3), blurRadius: 8)],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "หาคนเนียนในหมู่นักบิน",
                  style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNameInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _nameController,
              style: TextStyle(fontSize: 18),
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: "ใส่ชื่อเพื่อน... 🍺",
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                counterText: players.length >= 3 
                    ? "✓ พร้อมเล่น!" 
                    : "ขาดอีก ${3 - players.length} คน",
                counterStyle: TextStyle(
                  color: players.length >= 3 ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              onSubmitted: (_) => _addPlayer(),
            ),
          ),
          Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF00BCD4), Color(0xFF2196F3)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.person_add, color: Colors.white, size: 28),
              onPressed: _addPlayer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersList() {
    if (players.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_add, size: 80, color: Colors.white.withOpacity(0.5)),
            SizedBox(height: 16),
            Text(
              "ยังไม่มีใครเลย...\nเพิ่มเพื่อนเข้ามาสิ! 🎊",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.7), height: 1.5),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.people, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  "ผู้เล่น (${players.length})",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12),
              itemCount: players.length,
              itemBuilder: (context, index) {
                return _buildPlayerCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(int index) {
    final colors = [
      [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
      [Color(0xFF4ECDC4), Color(0xFF44A08D)],
      [Color(0xFFFFC371), Color(0xFFFF5F6D)],
      [Color(0xFF11998E), Color(0xFF38EF7D)],
      [Color(0xFFFC466B), Color(0xFF3F5EFB)],
    ];
    
    final gradientColors = colors[index % colors.length];

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: gradientColors[0].withOpacity(0.4), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Center(
            child: Text(
              "${index + 1}",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: gradientColors[0]),
            ),
          ),
        ),
        title: Text(
          players[index].name,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        trailing: IconButton(
          icon: Icon(Icons.close_rounded, color: Colors.white, size: 28),
          onPressed: () {
            setState(() => players.removeAt(index));
          },
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.05),
          child: Container(
            width: double.infinity,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53), Color(0xFFFFD93D)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Color(0xFFFF6B6B).withOpacity(0.6), blurRadius: 20, offset: Offset(0, 10))],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _startGame,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.flight_takeoff, color: Colors.white, size: 32),
                    SizedBox(width: 12),
                    Text(
                      "เริ่มเกม Ghost Pilot",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
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