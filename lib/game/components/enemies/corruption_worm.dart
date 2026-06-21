import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import 'base_enemy.dart';

class CorruptionWormHead extends BaseEnemy {
  final List<CorruptionWormSegment> segments = [];
  final List<Vector2> pathHistory = [];
  
  double _fireTimer = 0.0;
  final double _fireInterval = 1.5;
  
  double _time = 0.0;

  CorruptionWormHead({required Vector2 initialPosition}) : super(
    maxHp: Constants.corruptionWormHp,
    speed: Constants.corruptionWormSpeed,
    size: Vector2.all(32.0),
  ) {
    position = initialPosition;
    scoreValue = 200;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Spawn 5 segments
    for (int i = 0; i < 5; i++) {
      final segment = CorruptionWormSegment(head: this, index: i + 1);
      segments.add(segment);
      gameRef.world.add(segment);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    _time += dt;

    // Movement: Sinusoidal path downwards
    Vector2 dir = Vector2(sin(_time * 2), 1).normalized();
    position += dir * speed * dt;
    angle = atan2(dir.y, dir.x) + pi / 2;

    // Record path history
    pathHistory.insert(0, position.clone());
    if (pathHistory.length > 200) {
      pathHistory.removeLast();
    }

    // Shooting
    _fireTimer += dt;
    if (_fireTimer >= _fireInterval) {
      _fireTimer = 0.0;
      _fireSpread();
    }
  }

  void _fireSpread() {
    final dirs = [
      Vector2(0, 1),
      Vector2(-0.3, 1).normalized(),
      Vector2(0.3, 1).normalized(),
    ];
    for (final dir in dirs) {
      final bullet = gameRef.enemyBulletPool.acquire();
      bullet.fire(position, dir, 200.0);
    }
  }

  @override
  void die() {
    for (final seg in segments) {
      if (seg.parent != null) {
        seg.die();
      }
    }
    super.die();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..color = gameRef.appTheme.colors.neonGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..color = gameRef.appTheme.colors.neonGreen.withOpacity(0.2)
      ..style = PaintingStyle.fill;
      
    // Head shape
    final path = Path()
      ..moveTo(size.x / 2, 0)
      ..lineTo(size.x, size.y * 0.7)
      ..lineTo(size.x / 2, size.y)
      ..lineTo(0, size.y * 0.7)
      ..close();
    
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);
  }
}

class CorruptionWormSegment extends BaseEnemy {
  final CorruptionWormHead head;
  final int index;
  
  double _fireTimer = 0.0;
  final double _fireInterval = 2.0;
  
  CorruptionWormSegment({
    required this.head,
    required this.index,
  }) : super(
    maxHp: 9999.0, // Invincible, dies with head
    speed: 0.0,
    size: Vector2.all(24.0),
  ) {
    _fireTimer = index * 0.2; // Offset firing
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Follow history
    int historyIndex = index * 15;
    if (head.pathHistory.length > historyIndex) {
      position = head.pathHistory[historyIndex];
    } else if (head.pathHistory.isNotEmpty) {
      position = head.pathHistory.last;
    }

    _fireTimer += dt;
    if (_fireTimer >= _fireInterval) {
      _fireTimer = 0.0;
      _fireBullet();
    }
  }

  void _fireBullet() {
    if (head.parent == null) return;
    final bullet = gameRef.enemyBulletPool.acquire();
    bullet.fire(position, Vector2(0, 1), 150.0);
  }

  @override
  void takeDamage(double amount) {
    // Segments don't take damage directly
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..color = gameRef.appTheme.colors.neonGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..color = gameRef.appTheme.colors.neonGreen.withOpacity(0.2)
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle((size / 2).toOffset(), size.x / 2, fillPaint);
    canvas.drawCircle((size / 2).toOffset(), size.x / 2, paint);
  }
}
