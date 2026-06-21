import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'pickup_pool.dart';

class GamePickup extends PooledPickup {
  
  @override
  void renderPickup(Canvas canvas, AppTheme appTheme) {
    Color color;
    switch (type) {
      case PickupType.health:
        color = appTheme.colors.neonGreen;
        break;
      case PickupType.shield:
        color = appTheme.colors.neonCyan;
        break;
      case PickupType.weapon:
        color = appTheme.colors.neonMagenta;
        break;
      case PickupType.dataShard:
        color = appTheme.colors.neonAmber;
        break;
    }
    
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
      
    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
      
    final centerOffset = Offset(position.x, position.y);
    canvas.drawCircle(centerOffset, 8.0, fillPaint);
    canvas.drawCircle(centerOffset, 8.0, paint);
    
    if (appTheme.isDark) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(centerOffset, 12.0, glowPaint);
    }
  }
}
