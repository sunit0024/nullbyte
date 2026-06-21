import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class ExplosionVfx {
  static ParticleSystemComponent create({
    required Vector2 position,
    required Color color,
    int count = 20,
    double radius = 50.0,
  }) {
    final rnd = Random();
    
    return ParticleSystemComponent(
      position: position,
      particle: Particle.generate(
        count: count,
        lifespan: 0.5,
        generator: (i) {
          final angle = rnd.nextDouble() * 2 * pi;
          final speed = rnd.nextDouble() * radius * 4;
          final velocity = Vector2(cos(angle), sin(angle)) * speed;
          
          return AcceleratedParticle(
            speed: velocity,
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final paint = Paint()
                  ..color = color.withValues(alpha: 1.0 - particle.progress)
                  ..style = PaintingStyle.fill;
                canvas.drawCircle(Offset.zero, 3.0 * (1.0 - particle.progress), paint);
              },
            ),
          );
        },
      ),
    );
  }
}
