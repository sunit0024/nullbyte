import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../nullbyte_game.dart';

/// Helper to pick icon/text color that's visible on both light and dark themes.
Color _iconColor(NullbyteGame game) {
  return game.appTheme.isDark ? Colors.white : Colors.black87;
}

/// Base class for action buttons that orbit the shooting joystick.
/// [angleDeg] is the angle in degrees from the joystick center (0 = right, -90 = up).
/// [distanceFromJoystick] is the center-to-center distance from the joystick.
abstract class _JoystickOrbitButton extends PositionComponent with TapCallbacks, HasGameRef<NullbyteGame> {
  final JoystickComponent joystick;
  final double angleDeg;
  final double distanceFromJoystick;

  _JoystickOrbitButton({
    required this.joystick,
    required this.angleDeg,
    this.distanceFromJoystick = 95, // center-to-center distance
  }) : super(size: Vector2(60, 60), anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    // JoystickComponent (HudMarginComponent) position is already its center.
    final joystickCenter = joystick.position;
    final angleRad = angleDeg * pi / 180.0;
    position = joystickCenter + Vector2(
      cos(angleRad) * distanceFromJoystick,
      sin(angleRad) * distanceFromJoystick,
    );
  }
}

class ShieldButton extends _JoystickOrbitButton {
  ShieldButton({required super.joystick})
      : super(angleDeg: -135); // Top-left of joystick

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center = (size / 2).toOffset();
    final radius = size.x / 2;

    // Background
    final bgPaint = Paint()..color = gameRef.appTheme.colors.panelBg;
    canvas.drawCircle(center, radius, bgPaint);

    // Border — glows green when shield is active
    final isActive = gameRef.player.shieldActive;
    final borderPaint = Paint()
      ..color = isActive ? gameRef.appTheme.colors.neonGreen : gameRef.appTheme.colors.neonCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, borderPaint);

    // Label — theme-aware color
    final labelColor = isActive ? gameRef.appTheme.colors.neonGreen : _iconColor(gameRef);
    final textPaint = TextPaint(
      style: TextStyle(
        color: labelColor,
        fontSize: 12,
        fontFamily: 'Rajdhani',
        fontWeight: FontWeight.bold,
      ),
    );
    textPaint.render(
      canvas, 
      "SHIELD", 
      Vector2(size.x / 2, size.y / 2), 
      anchor: Anchor.center,
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    gameRef.player.toggleShield();
  }
}

class WeaponButton extends _JoystickOrbitButton {
  WeaponButton({required super.joystick})
      : super(angleDeg: -90); // Directly above joystick

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center = (size / 2).toOffset();
    final radius = size.x / 2;

    // Background
    final bgPaint = Paint()..color = gameRef.appTheme.colors.panelBg;
    canvas.drawCircle(center, radius, bgPaint);

    // Border
    final borderPaint = Paint()
      ..color = gameRef.appTheme.colors.neonMagenta
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, borderPaint);

    // Label — theme-aware color
    final textPaint = TextPaint(
      style: TextStyle(
        color: _iconColor(gameRef),
        fontSize: 12,
        fontFamily: 'Rajdhani',
        fontWeight: FontWeight.bold,
      ),
    );
    textPaint.render(
      canvas, 
      "WEAPON", 
      Vector2(size.x / 2, size.y / 2), 
      anchor: Anchor.center,
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    gameRef.player.cycleWeapon();
  }
}

class PauseButton extends PositionComponent with TapCallbacks, HasGameRef<NullbyteGame> {
  double _pulseTime = 0.0;

  PauseButton() : super(
    size: Vector2(44, 44),
    anchor: Anchor.center,
  );

  @override
  void update(double dt) {
    super.update(dt);
    _pulseTime += dt * 3;
    // Position in top-right corner with margin
    position = Vector2(gameRef.size.x - 40, 40);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center = (size / 2).toOffset();
    final radius = size.x / 2;
    final isPaused = gameRef.gamePaused;

    // Outer glow
    final glowAlpha = 0.15 + 0.05 * sin(_pulseTime);
    final glowPaint = Paint()
      ..color = gameRef.appTheme.colors.neonCyan.withValues(alpha: glowAlpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, radius + 4, glowPaint);

    // Background
    final bgPaint = Paint()
      ..color = gameRef.appTheme.colors.panelBg.withValues(alpha: 0.85);
    canvas.drawCircle(center, radius, bgPaint);

    // Border
    final borderPaint = Paint()
      ..color = gameRef.appTheme.colors.neonCyan.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, borderPaint);

    // Icon — theme-aware color
    final iconPaint = Paint()
      ..color = _iconColor(gameRef)
      ..style = PaintingStyle.fill;

    if (isPaused) {
      // Play triangle ▶
      final path = Path();
      path.moveTo(center.dx - 5, center.dy - 8);
      path.lineTo(center.dx - 5, center.dy + 8);
      path.lineTo(center.dx + 8, center.dy);
      path.close();
      canvas.drawPath(path, iconPaint);
    } else {
      // Pause bars ❚❚
      final barW = 4.0;
      final barH = 14.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(center.dx - 5, center.dy), width: barW, height: barH),
          const Radius.circular(1),
        ),
        iconPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(center.dx + 5, center.dy), width: barW, height: barH),
          const Radius.circular(1),
        ),
        iconPaint,
      );
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    gameRef.togglePause();
  }
}
