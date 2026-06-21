import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import 'base_enemy.dart';

class SentinelNode extends BaseEnemy {
  double _fireTimer = 0.0;
  final double _fireInterval = 1.5;
  
  double _pulseTime = 0.0;

  // orbit mechanics
  Vector2 orbitCenter;
  double orbitAngle = 0.0;
  final double orbitRadius = 80.0;

  SentinelNode({required this.orbitCenter}) : super(
    maxHp: Constants.sentinelHp,
    speed: Constants.sentinelSpeed,
    size: Vector2.all(40.0),
  ) {
    position = orbitCenter + Vector2(orbitRadius, 0);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    _pulseTime += dt * 5;

    // Movement: Orbit around the fixed point
    orbitAngle += (speed / orbitRadius) * dt;
    position = orbitCenter + Vector2(cos(orbitAngle), sin(orbitAngle)) * orbitRadius;

    // Shooting
    _fireTimer += dt;
    if (_fireTimer >= _fireInterval) {
      _fireTimer = 0.0;
      _fireBullet();
    }
  }

  void _fireBullet() {
    // Aim at player
    final dir = (gameRef.player.position - position).normalized();
    final bullet = gameRef.enemyBulletPool.acquire();
    bullet.fire(position, dir, 200.0);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final paint = Paint()
      ..color = gameRef.appTheme.colors.neonRed
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..color = gameRef.appTheme.colors.neonRed.withOpacity(0.2 + 0.1 * sin(_pulseTime))
      ..style = PaintingStyle.fill;
      
    // Draw octagonal shape
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
        ..color = gameRef.appTheme.colors.neonRed.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;
      canvas.drawPath(path, glowPaint);
    }
    
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);
  }
}
