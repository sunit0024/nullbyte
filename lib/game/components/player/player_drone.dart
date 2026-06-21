import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/constants.dart';
import '../../nullbyte_game.dart';
import '../pickups/pickup_pool.dart';

class PlayerDrone extends PositionComponent with HasGameRef<NullbyteGame> {
  final JoystickComponent joystick;
  
  Vector2 _velocity = Vector2.zero();
  double _tiltAngle = 0.0;
  double _pulseTime = 0.0;
  double _fireTimer = 0.0;
  
  double hp = 100.0;
  bool get isDead => hp <= 0;
  
  WeaponType currentWeapon = WeaponType.hexblast;
  int weaponTier = 1;

  // Shield mechanics
  double shield = 100.0;
  bool shieldActive = false;
  double _shieldRechargeTimer = 0.0;
  double _shieldLockoutTimer = 0.0;

  double get _currentFireRate {
    switch (currentWeapon) {
      case WeaponType.hexblast: return 8.0;
      case WeaponType.dataLance: return 3.0;
      case WeaponType.nullScatter: return 15.0;
    }
  }
  
  PlayerDrone({required this.joystick}) : super(
    size: Vector2.all(Constants.playerSize),
    anchor: Anchor.center,
  );

  void cycleWeapon() {
    int next = (currentWeapon.index + 1) % WeaponType.values.length;
    currentWeapon = WeaponType.values[next];
    _fireTimer = 0.0;
  }

  void toggleShield() {
    if (_shieldLockoutTimer > 0 || shield <= 0) return;
    shieldActive = !shieldActive;
    if (!shieldActive) {
      _shieldRechargeTimer = 0.0;
    }
  }

  void _shatterShield() {
    // Add particle effect later
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    _pulseTime += dt * 4; 

    // Shield logic
    if (shieldActive) {
      shield -= 15.0 * dt;
      if (shield <= 0) {
        shield = 0;
        shieldActive = false;
        _shieldLockoutTimer = 5.0;
        _shatterShield();
      }
    } else {
      if (_shieldLockoutTimer > 0) {
        _shieldLockoutTimer -= dt;
      } else {
        _shieldRechargeTimer += dt;
        if (_shieldRechargeTimer >= 3.0) {
          shield += 8.0 * dt;
          if (shield > 100.0) shield = 100.0;
        }
      }
    }

    _fireTimer += dt;
    if (_fireTimer >= 1.0 / _currentFireRate) {
      _fireTimer = 0.0;
      _fireBullet();
    }

    // Movement
    final currentSpeed = shieldActive ? Constants.playerBaseSpeed : Constants.playerBoostSpeed;
    final targetVelocity = joystick.direction != JoystickDirection.idle
      ? joystick.relativeDelta * currentSpeed 
      : Vector2.zero();
      
    _velocity.lerp(targetVelocity, 0.1);
    position += _velocity * dt;
    
    if (_velocity.length > 5.0) {
      final targetAngle = _velocity.x * (12.0 * pi / 180.0) / currentSpeed;
      _tiltAngle = _tiltAngle + (targetAngle - _tiltAngle) * 0.1;
    } else {
      _tiltAngle = _tiltAngle + (0 - _tiltAngle) * 0.1;
    }
    
    angle = _tiltAngle;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final center = size / 2;

    // Render Shield
    if (shieldActive || shield > 0) {
      final shieldPaint = Paint()
        ..color = gameRef.appTheme.colors.neonGreen.withValues(alpha: shieldActive ? 0.6 : 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      canvas.drawArc(
        Rect.fromCircle(center: center.toOffset(), radius: size.x / 2 + 10),
        -pi / 2, 
        (shield / 100.0) * 2 * pi, 
        false, 
        shieldPaint
      );
      
      if (shieldActive && gameRef.appTheme.isDark) {
         final glowPaint = Paint()
          ..color = gameRef.appTheme.colors.neonGreen.withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6.0;
         canvas.drawArc(
          Rect.fromCircle(center: center.toOffset(), radius: size.x / 2 + 10),
          -pi / 2, 
          (shield / 100.0) * 2 * pi, 
          false, 
          glowPaint
        );
      }
    }

    // Render Chassis
    final paint = Paint()
      ..color = gameRef.appTheme.colors.neonCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
      
    final fillPaint = Paint()
      ..color = gameRef.appTheme.colors.neonCyan.withValues(alpha: 0.2 + 0.1 * sin(_pulseTime))
      ..style = PaintingStyle.fill;
      
    final path = Path();
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
    
    _renderGlow(canvas, paint, path);
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);
  }

  void _renderGlow(Canvas canvas, Paint basePaint, Path path) {
    if (!gameRef.appTheme.isDark) return; 
    final glowColor = basePaint.color;
    for (int i = 3; i >= 1; i--) {
      final paint = Paint()
        ..color = glowColor.withValues(alpha: 0.08 * i)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 + (2.0 * (4 - i));
      canvas.drawPath(path, paint);
    }
  }

  void _fireBullet() {
    if (isDead) return;
    
    List<Vector2> dirs = [];
    switch (currentWeapon) {
      case WeaponType.hexblast:
        dirs = [
          Vector2(0, -1),
          Vector2(-0.2, -1).normalized(),
          Vector2(0.2, -1).normalized(),
        ];
        break;
      case WeaponType.dataLance:
        dirs = [Vector2(0, -1)];
        break;
      case WeaponType.nullScatter:
        for (int i = 0; i < 6; i++) {
          final angle = (-25 + i * 10) * pi / 180.0;
          dirs.add(Vector2(sin(angle), -cos(angle)));
        }
        break;
    }
    
    for (final dir in dirs) {
      final bullet = gameRef.playerBulletPool.acquire();
      bullet.fire(position, dir, 500.0, currentWeapon, weaponTier);
    }
  }

  void takeDamage(double amount) {
    if (isDead) return;
    if (shieldActive) return; // Absorbs 100% of damage
    
    hp -= amount;
    if (hp <= 0) {
      die();
    }
  }

  int dataShards = 0;

  void collectPickup(PickupType type) {
    switch (type) {
      case PickupType.health:
        hp += 25.0;
        if (hp > 100.0) hp = 100.0;
        break;
      case PickupType.shield:
        shield += 50.0;
        if (shield > 100.0) shield = 100.0;
        break;
      case PickupType.weapon:
        if (weaponTier < 3) weaponTier++;
        break;
      case PickupType.dataShard:
        dataShards++;
        break;
    }
  }

  void die() {
    removeFromParent();
  }
}
