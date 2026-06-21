import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../nullbyte_game.dart';

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

  // Joystick background radius = 50, button radius = 30.
  // Gap between edges = 130 - 50 - 30 = 50px of clear space.

  @override
  void update(double dt) {
    super.update(dt);
    // JoystickComponent (HudMarginComponent) position is already its center.
    // No need to add any offset.
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

    // Label
    final textPaint = TextPaint(
      style: TextStyle(
        color: isActive ? gameRef.appTheme.colors.neonGreen : Colors.white,
        fontSize: 12,
        fontFamily: 'Rajdhani',
        fontWeight: FontWeight.bold,
      ),
    );
    textPaint.render(canvas, "SHIELD", Vector2(10, 22));
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

    // Label
    final textPaint = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontFamily: 'Rajdhani',
        fontWeight: FontWeight.bold,
      ),
    );
    textPaint.render(canvas, "WEAPON", Vector2(8, 22));
  }

  @override
  void onTapDown(TapDownEvent event) {
    gameRef.player.cycleWeapon();
  }
}
