import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import 'base_enemy.dart';

class ProxyTurret extends BaseEnemy {
  double _fireTimer = 0.0;
  final double _fireInterval = 2.0;
  
  double _pulseTime = 0.0;

  ProxyTurret({required Vector2 initialPosition}) : super(
    maxHp: Constants.proxyTurretHp,
    speed: 0,
    size: Vector2.all(48.0),
  ) {
    position = initialPosition;
    scoreValue = 100;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    _pulseTime += dt * 4;

    _fireTimer += dt;
    
    if (_fireTimer >= _fireInterval) {
      _fireTimer = 0.0;
      _fireBurst();
    }
  }

  void _fireBurst() {
    int ways = hp < maxHp * 0.5 ? 16 : 8;
    for (int i = 0; i < ways; i++) {
      final angle = (i * (360 / ways)) * pi / 180.0;
      final dir = Vector2(cos(angle), sin(angle));
      final bullet = gameRef.enemyBulletPool.acquire();
      bullet.fire(position, dir, 150.0);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final paint = Paint()
      ..color = gameRef.appTheme.colors.neonAmber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..color = gameRef.appTheme.colors.neonAmber.withOpacity(0.2)
      ..style = PaintingStyle.fill;
      
    final path = Path();
    final center = size / 2;
    final r = size.x / 2;
    
    for (int i = 0; i < 6; i++) {
      final theta = (i * 60) * pi / 180.0;
      final px = center.x + r * cos(theta);
      final py = center.y + r * sin(theta);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    
    // Warning light
    if (_fireTimer > _fireInterval - 0.5) {
       final warningPaint = Paint()
         ..color = gameRef.appTheme.colors.neonRed
         ..style = PaintingStyle.fill;
       canvas.drawCircle((size / 2).toOffset(), 10.0 + 5.0 * sin(_pulseTime * 2), warningPaint);
       
       if (gameRef.appTheme.isDark) {
         final glowPaint = Paint()
          ..color = gameRef.appTheme.colors.neonRed.withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0)
          ..style = PaintingStyle.fill;
         canvas.drawCircle((size / 2).toOffset(), 15.0, glowPaint);
       }
    } else {
       final capPaint = Paint()
         ..color = gameRef.appTheme.colors.panelBg
         ..style = PaintingStyle.fill;
       canvas.drawCircle((size / 2).toOffset(), 10.0, capPaint);
       canvas.drawCircle((size / 2).toOffset(), 10.0, paint);
    }
    
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);
  }
}
