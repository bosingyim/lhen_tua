class Player {
  String name; //ชื่อผู้เล่น
  String? role; //บท
  String? secretWord; //คำลับ

  Player({
    required this.name,
    this.role,
    this.secretWord,
  });

  get isGhost => null;
}