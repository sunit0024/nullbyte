import 'dart:math';
import 'package:flame/components.dart';
import '../../nullbyte_game.dart';
import '../pickups/pickup_pool.dart';
import '../vfx/explosion.dart';

abstract class BaseEnemy extends PositionComponent with HasGameRef<NullbyteGame> {
  double hp;
  double maxHp;
  double speed;
  int scoreValue = 50;

  BaseEnemy({
    required this.maxHp,
    required this.speed,
    required Vector2 size,
  }) : hp = maxHp, super(size: size, anchor: Anchor.center);

  void takeDamage(double amount) {
    hp -= amount;
    if (hp <= 0) {
      gameRef.scoringSystem.addScore(scoreValue);
      die();
    }
  }

  void die() {
    // Spawn explosion particle
    gameRef.world.add(ExplosionVfx.create(
      position: position,
      color: gameRef.appTheme.colors.neonAmber,
      count: 20,
      radius: size.x,
    ));
    
    // Drop logic
    final rnd = Random();
    if (rnd.nextDouble() < 0.2) { // 20% drop rate
      final type = PickupType.values[rnd.nextInt(PickupType.values.length)];
      gameRef.pickupPool.acquire(position, type);
    }
    gameRef.shake(intensity: 5.0, duration: 0.1);
    removeFromParent();
  }
}
