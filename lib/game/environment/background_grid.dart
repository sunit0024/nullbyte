import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../nullbyte_game.dart';

class BackgroundGrid extends Component with HasGameRef<NullbyteGame> {
  static const double gridSize = 100.0;
  
  late Paint gridPaint;
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    _updatePaint();
  }

  void _updatePaint() {
    gridPaint = Paint()
      ..color = gameRef.appTheme.colors.grid
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
  }

  @override
  void render(Canvas canvas) {
    _updatePaint(); 
    
    final cameraRect = gameRef.camera.visibleWorldRect;
    final left = cameraRect.left;
    final top = cameraRect.top;
    final right = cameraRect.right;
    final bottom = cameraRect.bottom;

    final startX = (left / gridSize).floor() * gridSize;
    final startY = (top / gridSize).floor() * gridSize;

    for (double x = startX; x <= right; x += gridSize) {
      canvas.drawLine(Offset(x, top), Offset(x, bottom), gridPaint);
    }
    
    for (double y = startY; y <= bottom; y += gridSize) {
      canvas.drawLine(Offset(left, y), Offset(right, y), gridPaint);
    }
  }
}
