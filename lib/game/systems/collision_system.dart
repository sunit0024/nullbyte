import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import '../nullbyte_game.dart';
import '../components/enemies/base_enemy.dart';

class CollisionSystem extends Component with HasGameRef<NullbyteGame> {
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Player bullets vs Enemies
    final activePlayerBullets = gameRef.playerBulletPool.activeBullets;
    final enemies = gameRef.world.children.whereType<BaseEnemy>().toList();
    
    for (int i = activePlayerBullets.length - 1; i >= 0; i--) {
      final bullet = activePlayerBullets[i];
      final bulletRect = Rect.fromCenter(
        center: Offset(bullet.position.x, bullet.position.y), 
        width: 8, height: 8
      );
      
      for (final enemy in enemies) {
        if (enemy.hp <= 0) continue;
        
        final enemyRect = Rect.fromCenter(
          center: Offset(enemy.position.x, enemy.position.y),
          width: enemy.size.x, height: enemy.size.y
        );
        
        if (bulletRect.overlaps(enemyRect)) {
          enemy.takeDamage(bullet.damage);
          if (!bullet.piercing) {
            gameRef.playerBulletPool.release(bullet);
          }
          break; 
        }
      }
    }
    
    if (gameRef.player.isDead) return;
    
    // Enemy bullets vs Player
    final activeEnemyBullets = gameRef.enemyBulletPool.activeBullets;
    final playerRect = Rect.fromCenter(
      center: Offset(gameRef.player.position.x, gameRef.player.position.y),
      width: gameRef.player.size.x * 0.5,
      height: gameRef.player.size.y * 0.5
    );
    
    for (int i = activeEnemyBullets.length - 1; i >= 0; i--) {
      final bullet = activeEnemyBullets[i];
       final bulletRect = Rect.fromCenter(
        center: Offset(bullet.position.x, bullet.position.y), 
        width: 8, height: 8
      );
      
      if (bulletRect.overlaps(playerRect)) {
        gameRef.player.takeDamage(10.0);
        gameRef.enemyBulletPool.release(bullet);
      }
    }
    
    // Enemies vs Player body
    for (final enemy in enemies) {
      if (enemy.hp <= 0) continue;
      
       final enemyRect = Rect.fromCenter(
          center: Offset(enemy.position.x, enemy.position.y),
          width: enemy.size.x, height: enemy.size.y
        );
        
        if (enemyRect.overlaps(playerRect)) {
           gameRef.player.takeDamage(20.0);
           enemy.takeDamage(999.0); // Destroy enemy
        }
    }
    
    // Player vs Pickups
    final activePickups = gameRef.pickupPool.activePickups;
    for (int i = activePickups.length - 1; i >= 0; i--) {
      final pickup = activePickups[i];
      final pickupRect = Rect.fromCenter(
        center: Offset(pickup.position.x, pickup.position.y),
        width: 16, height: 16
      );
      
      if (pickupRect.overlaps(playerRect)) {
        gameRef.player.collectPickup(pickup.type);
        gameRef.pickupPool.release(pickup);
      }
    }
  }
}
