import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'base_enemy.dart';

enum BossPhase { phase1, phase2 }

class SystemCoreBoss extends BaseEnemy {
  BossPhase _phase = BossPhase.phase1;
  double _fireTimer = 0.0;
  double _specialTimer = 0.0;
  double _pulseTime = 0.0;
  double _moveTimer = 0.0;

  SystemCoreBoss({required Vector2 initialPosition}) : super(
    maxHp: 2000.0,
    speed: 50.0,
    size: Vector2.all(120.0),
  ) {
    position = initialPosition;
    scoreValue = 1000;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isPaused) return;
    _pulseTime += dt * 2;
    _fireTimer += dt;
    _specialTimer += dt;

    if (_phase == BossPhase.phase1) {
      if (_fireTimer > 1.0) {
        _fireTimer = 0.0;
        _fireRing(12, 100.0);
      }
      
      if (_specialTimer > 4.0) {
        _specialTimer = 0.0;
        _fireRing(24, 150.0);
      }

      if (hp < maxHp * 0.5) {
        _phase = BossPhase.phase2;
        _fireTimer = 0.0;
        _specialTimer = 0.0;
      }
    } else {
      _moveTimer += dt;
      
      final toPlayer = gameRef.player.position - position;
      final dist = toPlayer.length;
      final dir = toPlayer.normalized();

      if (dist > 150.0) {
        position += dir * speed * dt;
      }
      
      angle = atan2(dir.y, dir.x) + pi/2;

      if (_fireTimer > 0.5) {
        _fireTimer = 0.0;
        _fireSpread(dir);
      }
      
      if (_specialTimer > 3.0) {
        _specialTimer = 0.0;
        _fireRing(16, 200.0);
      }
    }
  }

  void _fireRing(int count, double speed) {
    for (int i = 0; i < count; i++) {
      final a = (i * 360 / count) * pi / 180.0;
      final dir = Vector2(cos(a), sin(a));
      final bullet = gameRef.enemyBulletPool.acquire();
      bullet.fire(position, dir, speed);
    }
  }

  void _fireSpread(Vector2 baseDir) {
    final dirs = [
      baseDir,
      Vector2(baseDir.x * cos(0.2) - baseDir.y * sin(0.2), baseDir.x * sin(0.2) + baseDir.y * cos(0.2)),
      Vector2(baseDir.x * cos(-0.2) - baseDir.y * sin(-0.2), baseDir.x * sin(-0.2) + baseDir.y * cos(-0.2)),
    ];
    for (final dir in dirs) {
      final bullet = gameRef.enemyBulletPool.acquire();
      bullet.fire(position, dir, 250.0);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final isEnraged = _phase == BossPhase.phase2;
    final primaryColor = isEnraged ? gameRef.appTheme.colors.neonRed : gameRef.appTheme.colors.neonMagenta;
    
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final fillPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.2 + 0.1 * sin(_pulseTime))
      ..style = PaintingStyle.fill;
      
    final path = Path();
    final center = size / 2;
    final r = size.x / 2;
    
    for (int i = 0; i < 8; i++) {
      final theta = (i * 45) * pi / 180.0;
      final px = center.x + r * cos(theta);
      final py = center.y + r * sin(theta);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    
    if (gameRef.appTheme.isDark) {
      final glowPaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15.0)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, glowPaint);
    }
    
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);
    
    final corePaint = Paint()
      ..color = gameRef.appTheme.colors.neonAmber
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.x, center.y), 20.0 + 5.0 * sin(_pulseTime * 4), corePaint);
  }
}
