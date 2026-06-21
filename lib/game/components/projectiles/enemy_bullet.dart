import 'dart:ui';
import 'package:flame/components.dart';
import '../../../core/theme/app_theme.dart';
import 'bullet_pool.dart';

class EnemyBullet extends PooledBullet {
  Vector2 position = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  double lifetime = 3.0;
  double _elapsed = 0.0;
  
  final AppTheme appTheme;

  EnemyBullet({required this.appTheme});

  @override
  bool get isExpired => _elapsed >= lifetime;

  @override
  void activate() {
    super.activate();
    _elapsed = 0.0;
  }

  void fire(Vector2 startPosition, Vector2 dir, double speed) {
    position.setFrom(startPosition);
    velocity = dir * speed;
  }

  @override
  void updateBullet(double dt) {
    _elapsed += dt;
    position += velocity * dt;
  }

  @override
  void renderBullet(Canvas canvas) {
    final paint = Paint()
      ..color = appTheme.colors.neonRed
      ..style = PaintingStyle.fill;
      
    // Simple diamond shape
    final path = Path()
      ..moveTo(position.x, position.y - 6)
      ..lineTo(position.x + 4, position.y)
      ..lineTo(position.x, position.y + 6)
      ..lineTo(position.x - 4, position.y)
      ..close();
      
    canvas.drawPath(path, paint);
    
    if (appTheme.isDark) {
      final glowPaint = Paint()
        ..color = appTheme.colors.neonRed.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, glowPaint);
    }
  }
}
