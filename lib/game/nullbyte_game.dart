import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_theme.dart';
import '../core/constants.dart';
import 'environment/background_grid.dart';
import 'components/player/player_drone.dart';
import 'components/projectiles/bullet_pool.dart';
import 'components/projectiles/player_bullet.dart';
import 'components/projectiles/enemy_bullet.dart';
import 'systems/collision_system.dart';
import 'systems/wave_system.dart';
import 'systems/scoring_system.dart';
import 'components/pickups/pickup_pool.dart';
import 'components/pickups/game_pickup.dart';
import '../core/save_manager.dart';
import 'dart:math';

class NullbyteGame extends FlameGame with HasCollisionDetection, KeyboardEvents {
  final AppTheme appTheme;

  NullbyteGame({required this.appTheme});

  late BackgroundGrid backgroundGrid;
  late PlayerDrone player;
  late JoystickComponent joystick;
  late JoystickComponent shootingJoystick;
  
  late BulletPool<PlayerBullet> playerBulletPool;
  late BulletPool<EnemyBullet> enemyBulletPool;
  late PickupPool pickupPool;
  late ScoringSystem scoringSystem;
  
  bool isPlaying = false;
  
  double _shakeTimer = 0.0;
  double _shakeIntensity = 0.0;
  final _rnd = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Init Pools
    playerBulletPool = BulletPool<PlayerBullet>(
      factory: () => PlayerBullet(appTheme: appTheme),
      initialSize: Constants.playerBulletPoolSize,
    );
    await world.add(BulletPoolComponent(pool: playerBulletPool));

    enemyBulletPool = BulletPool<EnemyBullet>(
      factory: () => EnemyBullet(appTheme: appTheme),
      initialSize: Constants.enemyBulletPoolSize,
    );
    await world.add(BulletPoolComponent(pool: enemyBulletPool));

    pickupPool = PickupPool(
      factory: () => GamePickup(),
      initialSize: Constants.pickupPoolSize,
    );
    await world.add(PickupPoolComponent(pool: pickupPool, appTheme: appTheme));

    // Add background
    backgroundGrid = BackgroundGrid();
    await world.add(backgroundGrid);

    // Setup joystick
    final knobPaint = Paint()..color = appTheme.colors.neonCyan.withValues(alpha: 0.8);
    final backgroundPaint = Paint()..color = appTheme.colors.panelBg;

    joystick = JoystickComponent(
      knob: CircleComponent(radius: 20, paint: knobPaint),
      background: CircleComponent(radius: 50, paint: backgroundPaint),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );
    
    shootingJoystick = JoystickComponent(
      knob: CircleComponent(radius: 20, paint: knobPaint),
      background: CircleComponent(radius: 50, paint: backgroundPaint),
      margin: const EdgeInsets.only(right: 40, bottom: 40),
    );
    
    // Add joysticks to viewport
    camera.viewport.add(joystick);
    camera.viewport.add(shootingJoystick);

    // Add player
    player = PlayerDrone(joystick: joystick, shootingJoystick: shootingJoystick);
    await world.add(player);

    // Setup camera
    camera.follow(player);

    // Add Systems
    await world.add(CollisionSystem());
    await world.add(WaveSystem());
    scoringSystem = ScoringSystem();
    await world.add(scoringSystem);
    
    // Add Boss HP Bar to viewport
    camera.viewport.add(BossHpBar());
    
    // Start paused
    pauseEngine();
  }
  
  void startGame() {
    isPlaying = true;
    scoringSystem.score = 0;
    scoringSystem.combo = 1;
    // reset player, wave system, etc.
    // For now we just resume engine
    resumeEngine();
  }
  
  void gameOver() {
    isPlaying = false;
    pauseEngine();
    
    // Save progression
    SaveManager.saveHighScore(scoringSystem.score);
    final waveSystem = world.children.whereType<WaveSystem>().first;
    SaveManager.saveMaxSector(waveSystem.sector);
    
    // Show game over overlay
    overlays.add('MainMenu'); // Temporary, back to main menu
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.tab) {
        player.cycleWeapon();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.space) {
        player.toggleShield();
        return KeyEventResult.handled;
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isPlaying) return;

    if (_shakeTimer > 0) {
      _shakeTimer -= dt;
      camera.viewfinder.position = player.position + Vector2(
        (_rnd.nextDouble() - 0.5) * _shakeIntensity,
        (_rnd.nextDouble() - 0.5) * _shakeIntensity,
      );
    } else {
      camera.viewfinder.position = player.position;
    }
  }

  void shake({double intensity = 10.0, double duration = 0.2}) {
    _shakeIntensity = intensity;
    _shakeTimer = duration;
  }

  @override
  Color backgroundColor() => appTheme.colors.background;
}
