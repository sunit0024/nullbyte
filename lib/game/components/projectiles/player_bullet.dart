import 'dart:ui';
import 'package:flame/components.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants.dart';
import 'bullet_pool.dart';

class PlayerBullet extends PooledBullet {
  Vector2 position = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  double lifetime = 1.5;
  double _elapsed = 0.0;
  
  WeaponType type = WeaponType.hexblast;
  int tier = 1;
  double damage = 12.0;
  bool piercing = false;
  
  final AppTheme appTheme;

  PlayerBullet({required this.appTheme});

  @override
  bool get isExpired => _elapsed >= lifetime;

  @override
  void activate() {
    super.activate();
    _elapsed = 0.0;
    piercing = false;
  }

  void fire(Vector2 startPosition, Vector2 dir, double speed, WeaponType weaponType, int weaponTier) {
    position.setFrom(startPosition);
    velocity = dir * speed;
    type = weaponType;
    tier = weaponTier;
    
    switch (type) {
      case WeaponType.hexblast:
        damage = tier == 1 ? 12.0 : (tier == 2 ? 15.6 : 19.2);
        lifetime = 1.5;
        break;
      case WeaponType.dataLance:
        damage = tier == 1 ? 45.0 : (tier == 2 ? 58.5 : 72.0);
        piercing = true;
        lifetime = 0.5;
        break;
      case WeaponType.nullScatter:
        damage = tier == 1 ? 6.0 : (tier == 2 ? 7.8 : 9.6);
        lifetime = 1.0;
        break;
    }
  }

  @override
  void updateBullet(double dt) {
    _elapsed += dt;
    position += velocity * dt;
  }

  @override
  void renderBullet(Canvas canvas) {
    Paint paint;
    Paint? glowPaint;
    
    switch (type) {
      case WeaponType.hexblast:
        paint = Paint()..color = appTheme.colors.neonCyan..style = PaintingStyle.fill;
        canvas.drawCircle(position.toOffset(), tier >= 2 ? 6.0 : 4.0, paint);
        if (appTheme.isDark) {
          glowPaint = Paint()
            ..color = appTheme.colors.neonCyan.withOpacity(0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(position.toOffset(), tier >= 2 ? 10.0 : 8.0, glowPaint);
        }
        break;
        
      case WeaponType.dataLance:
        paint = Paint()..color = appTheme.colors.neonMagenta..style = PaintingStyle.stroke..strokeWidth = tier >= 2 ? 6.0 : 3.0;
        final endPosition = position + velocity.normalized() * (tier >= 2 ? 60.0 : 40.0);
        canvas.drawLine(position.toOffset(), endPosition.toOffset(), paint);
        if (appTheme.isDark) {
          glowPaint = Paint()
            ..color = appTheme.colors.neonMagenta.withOpacity(0.5)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0)
            ..style = PaintingStyle.stroke
            ..strokeWidth = tier >= 2 ? 12.0 : 8.0;
          canvas.drawLine(position.toOffset(), endPosition.toOffset(), glowPaint);
        }
        break;
        
      case WeaponType.nullScatter:
        paint = Paint()..color = appTheme.colors.neonAmber..style = PaintingStyle.fill;
        canvas.drawCircle(position.toOffset(), tier >= 2 ? 4.0 : 3.0, paint);
        if (appTheme.isDark) {
          glowPaint = Paint()
            ..color = appTheme.colors.neonAmber.withOpacity(0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(position.toOffset(), tier >= 2 ? 8.0 : 6.0, glowPaint);
        }
        break;
    }
  }
}
