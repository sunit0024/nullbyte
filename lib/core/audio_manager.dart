import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

class AudioManager {
  static bool _initialized = false;
  
  static Future<void> init() async {
    try {
      // In a real app we would pre-load assets:
      // await FlameAudio.audioCache.loadAll(['shoot.mp3', 'explosion.mp3', 'bgm.mp3']);
      _initialized = true;
    } catch (e) {
      debugPrint('Failed to init audio: $e');
    }
  }

  static void playBgm() {
    if (!_initialized) return;
    try {
      // FlameAudio.bgm.play('bgm.mp3');
      debugPrint('Playing BGM (Mock)');
    } catch (e) {
      debugPrint('BGM Error: $e');
    }
  }

  static void stopBgm() {
    if (!_initialized) return;
    try {
      // FlameAudio.bgm.stop();
      debugPrint('Stopped BGM (Mock)');
    } catch (e) {
      debugPrint('BGM Error: $e');
    }
  }

  static void playSfx(String sound) {
    if (!_initialized) return;
    try {
      // FlameAudio.play('$sound.mp3');
      debugPrint('Playing SFX: $sound (Mock)');
    } catch (e) {
      debugPrint('SFX Error: $e');
    }
  }
}
