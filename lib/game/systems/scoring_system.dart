import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../nullbyte_game.dart';
import '../components/enemies/system_core_boss.dart';

class ScoringSystem extends Component with HasGameRef<NullbyteGame> {
  int score = 0;
  int combo = 1;
  double comboTimer = 0.0;

  late TextComponent scoreText;
  late TextComponent comboText;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    scoreText = TextComponent(
      text: 'SCORE: 0',
      position: Vector2(20, 20),
      textRenderer: TextPaint(
        style: TextStyle(
          color: gameRef.appTheme.colors.neonCyan,
          fontSize: 24,
          fontFamily: 'Rajdhani',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    
    comboText = TextComponent(
      text: 'COMBO: x1',
      position: Vector2(20, 50),
      textRenderer: TextPaint(
        style: TextStyle(
          color: gameRef.appTheme.colors.neonAmber,
          fontSize: 20,
          fontFamily: 'Rajdhani',
        ),
      ),
    );
    
    gameRef.camera.viewport.add(scoreText);
    gameRef.camera.viewport.add(comboText);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (combo > 1) {
      comboTimer -= dt;
      if (comboTimer <= 0) {
        combo = 1;
        comboText.text = 'COMBO: x1';
      }
    }
  }

  void addScore(int amount) {
    score += amount * combo;
    combo++;
    comboTimer = 5.0;
    
    scoreText.text = 'SCORE: $score';
    comboText.text = 'COMBO: x$combo';
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // The ScoringSystem component is in the world, so rendering here would use world coordinates.
    // Instead, let's just let the camera viewport handle UI.
  }
}

class BossHpBar extends Component with HasGameRef<NullbyteGame> {
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final bosses = gameRef.world.children.whereType<SystemCoreBoss>().toList();
    if (bosses.isNotEmpty) {
      final boss = bosses.first;
      final hpPercentage = boss.hp / boss.maxHp;
      
      final barWidth = 400.0;
      final barHeight = 20.0;
      // Hardcode viewport width for now, or use gameRef.canvasSize
      final x = (gameRef.size.x - barWidth) / 2;
      final y = 20.0;
      
      final bgPaint = Paint()..color = Colors.black54;
      canvas.drawRect(Rect.fromLTWH(x, y, barWidth, barHeight), bgPaint);
      
      final hpColor = boss.hp < boss.maxHp * 0.5 ? gameRef.appTheme.colors.neonRed : gameRef.appTheme.colors.neonMagenta;
      final hpPaint = Paint()..color = hpColor;
      canvas.drawRect(Rect.fromLTWH(x, y, barWidth * hpPercentage, barHeight), hpPaint);
      
      final borderPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawRect(Rect.fromLTWH(x, y, barWidth, barHeight), borderPaint);
      
      // Boss Title
      final textPaint = TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'Rajdhani',
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
      );
      textPaint.render(canvas, "SYSTEM CORE", Vector2(x + barWidth / 2 - 50, y + 25));
    }
  }
}

class PlayerHpBar extends Component with HasGameRef<NullbyteGame> {
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    if (gameRef.player.isDead) return;
    
    final hpPercentage = (gameRef.player.hp / 100.0).clamp(0.0, 1.0);
    final shieldPercentage = (gameRef.player.shield / 100.0).clamp(0.0, 1.0);
    
    final barWidth = 200.0;
    final barHeight = 12.0;
    
    // Position at top left under the SCORE and COMBO text
    final x = 50.0;
    final y = 90.0;
    
    // HP Bar
    final bgPaint = Paint()..color = Colors.black54;
    canvas.drawRect(Rect.fromLTWH(x, y, barWidth, barHeight), bgPaint);
    
    final hpColor = gameRef.player.hp < 30 ? gameRef.appTheme.colors.neonRed : gameRef.appTheme.colors.neonGreen;
    final hpPaint = Paint()..color = hpColor;
    canvas.drawRect(Rect.fromLTWH(x, y, barWidth * hpPercentage, barHeight), hpPaint);
    
    // Shield Bar
    final shieldY = y + 16.0;
    canvas.drawRect(Rect.fromLTWH(x, shieldY, barWidth, barHeight), bgPaint);
    
    final shieldColor = gameRef.appTheme.colors.neonCyan;
    final shieldPaint = Paint()..color = shieldColor;
    canvas.drawRect(Rect.fromLTWH(x, shieldY, barWidth * shieldPercentage, barHeight), shieldPaint);
    
    // Borders
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(Rect.fromLTWH(x, y, barWidth, barHeight), borderPaint);
    canvas.drawRect(Rect.fromLTWH(x, shieldY, barWidth, barHeight), borderPaint);
    
    // Labels
    final textPaint = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontFamily: 'Rajdhani',
        fontWeight: FontWeight.bold,
      ),
    );
    textPaint.render(canvas, "HP", Vector2(x - 20, y - 1));
    textPaint.render(canvas, "SHIELD", Vector2(x - 38, shieldY - 1));
  }
}
