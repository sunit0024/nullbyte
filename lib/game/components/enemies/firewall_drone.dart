import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import 'base_enemy.dart';

enum FirewallState { idle, accelerating, gliding, attacking }

class FirewallDrone extends BaseEnemy {
  FirewallState _state = FirewallState.idle;
  double _stateTimer = 0.0;
  Vector2 _velocity = Vector2.zero();
  
  double _pulseTime = 0.0;
  
  FirewallDrone({required Vector2 initialPosition}) : super(
    maxHp: Constants.firewallHp,
    speed: Constants.firewallSpeed,
    size: Vector2(24.0, 48.0),
  ) {
    position = initialPosition;
    scoreValue = 30;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isPaused) return;
    _pulseTime += dt * 8;
    _stateTimer += dt;
    
    final toPlayer = gameRef.player.position - position;
    final distToPlayer = toPlayer.length;
    final dirToPlayer = toPlayer.normalized();

    // State machine
    switch (_state) {
      case FirewallState.idle:
        _velocity.lerp(Vector2.zero(), 0.1);
        angle = _velocity.length > 5.0 ? atan2(_velocity.y, _velocity.x) + pi/2 : atan2(dirToPlayer.y, dirToPlayer.x) + pi/2;
        if (_stateTimer > 1.0) {
          _state = distToPlayer < 200.0 ? FirewallState.attacking : FirewallState.accelerating;
          _stateTimer = 0.0;
        }
        break;
      case FirewallState.accelerating:
        _velocity = dirToPlayer * speed;
        angle = atan2(dirToPlayer.y, dirToPlayer.x) + pi/2;
        if (_stateTimer > 0.4) {
          _state = FirewallState.gliding;
          _stateTimer = 0.0;
        }
        break;
      case FirewallState.gliding:
        _velocity.lerp(Vector2.zero(), 0.05);
        angle = atan2(_velocity.y, _velocity.x) + pi/2;
        if (_stateTimer > 0.8) {
          _state = FirewallState.idle;
          _stateTimer = 0.0;
        }
        break;
      case FirewallState.attacking:
        _velocity.lerp(Vector2.zero(), 0.1);
        angle = atan2(dirToPlayer.y, dirToPlayer.x) + pi/2;
        if (_stateTimer > 0.5) {
          _fireBurst(dirToPlayer);
          _state = FirewallState.idle;
          _stateTimer = 0.0;
        }
        break;
    }
    
    position += _velocity * dt;
  }

  void _fireBurst(Vector2 dirToPlayer) {
    // 3-shot spread burst
    final dirs = [
      dirToPlayer,
      Vector2(dirToPlayer.x * cos(0.3) - dirToPlayer.y * sin(0.3), dirToPlayer.x * sin(0.3) + dirToPlayer.y * cos(0.3)),
      Vector2(dirToPlayer.x * cos(-0.3) - dirToPlayer.y * sin(-0.3), dirToPlayer.x * sin(-0.3) + dirToPlayer.y * cos(-0.3)),
    ];
    
    for (final dir in dirs) {
      final bullet = gameRef.enemyBulletPool.acquire();
      bullet.fire(position, dir.normalized(), 300.0);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final paint = Paint()
      ..color = gameRef.appTheme.colors.neonMagenta
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..color = gameRef.appTheme.colors.neonMagenta.withOpacity(0.2 + 0.1 * sin(_pulseTime))
      ..style = PaintingStyle.fill;
      
    // Narrow diamond
    final path = Path()
      ..moveTo(size.x / 2, 0)
      ..lineTo(size.x, size.y / 2)
      ..lineTo(size.x / 2, size.y)
      ..lineTo(0, size.y / 2)
      ..close();
    
    if (gameRef.appTheme.isDark && _state == FirewallState.accelerating) {
      final glowPaint = Paint()
        ..color = gameRef.appTheme.colors.neonMagenta.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, glowPaint);
    }
    
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);
  }
}
