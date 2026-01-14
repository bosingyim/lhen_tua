import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import '../models/player.dart';

class GameService {
  
  // โหลดไฟล์ JSON (Helper Function)
  Future<Map<String, dynamic>> _loadData() async {
    final String response = await rootBundle.loadString('assets/words.json');
    return json.decode(response);
  }

  // ---------------------------------------------------
  // ฟังก์ชัน 1: ตั้งค่าเกม Ghost Pilot
  // ---------------------------------------------------
  Future<List<Player>> setupGhostPilot(List<Player> players) async {
    final data = await _loadData();

    // จุดที่แก้: เข้าไปที่ ['ghost_pilot']['words']
    List<dynamic> wordList = data['ghost_pilot']['words'];

    final random = Random();
    var wordPair = wordList[random.nextInt(wordList.length)];
    
    String crewWord = wordPair['crew'];
    String ghostWord = wordPair['ghost'];

    int ghostIndex = random.nextInt(players.length);

    for (int i = 0; i < players.length; i++) {
      if (i == ghostIndex) {
        players[i].role = 'ผี';
        players[i].secretWord = ghostWord;
      } else {
        players[i].role = 'ลูกเรือ';
        players[i].secretWord = crewWord;
      }
    }
    return players;
  }

  // ---------------------------------------------------
  // ฟังก์ชัน 2: สุ่มคำถาม (ระบุชื่อเกมได้แล้ว!)
  // ---------------------------------------------------
  Future<String> getRandomQuestion(String gameKey) async {
    final data = await _loadData();

    // จุดที่แก้: ดึงคำถามจาก gameKey ที่ระบุ (เช่น 'ghost_pilot')
    if (data[gameKey] == null || data[gameKey]['questions'] == null) {
      return "ไม่พบคำถามสำหรับเกมนี้";
    }

    List<dynamic> questions = data[gameKey]['questions'];

    if (questions.isEmpty) return "คำถามหมดแล้ว!";

    final random = Random();
    return questions[random.nextInt(questions.length)];
  }

  // ---------------------------------------------------
  // ฟังก์ชัน 3: สุ่มเหตุการณ์ (ใช้ร่วมกัน หรือแยกก็ได้)
  // ---------------------------------------------------
  Future<String> getRandomEvent(String gameKey) async {
    final data = await _loadData();

    //1.หา events ของเกมนั้น
    if (data[gameKey] != null && data[gameKey]['events'] != null) {
      List<dynamic> gameEvents = data[gameKey]['events'];
      if (gameEvents.isNotEmpty) {
        final random = Random();
        return gameEvents[random.nextInt(gameEvents.length)];
      }
    }
    //2.ถ้าไม่มี events ของเกมนั้น ให้ใช้ events ทั่วไป
    if (data['events'] != null) {
      List<dynamic> globalEvents = data['events'];
      final random = Random();
      return globalEvents[random.nextInt(globalEvents.length)];
    }

    return "ไม่มี Event ในช่วงนี้";
  }
}

