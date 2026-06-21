import 'package:shared_preferences/shared_preferences.dart';

class SaveManager {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static int getHighScore() {
    return _prefs.getInt('highScore') ?? 0;
  }

  static Future<void> saveHighScore(int score) async {
    final currentHigh = getHighScore();
    if (score > currentHigh) {
      await _prefs.setInt('highScore', score);
    }
  }

  static int getMaxSector() {
    return _prefs.getInt('maxSector') ?? 1;
  }

  static Future<void> saveMaxSector(int sector) async {
    final currentMax = getMaxSector();
    if (sector > currentMax) {
      await _prefs.setInt('maxSector', sector);
    }
  }
}
