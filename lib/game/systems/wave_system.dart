import 'dart:math';
import 'package:flame/components.dart';
import '../nullbyte_game.dart';
import '../components/enemies/base_enemy.dart';
import '../components/enemies/sentinel_node.dart';
import '../components/enemies/firewall_drone.dart';
import '../components/enemies/proxy_turret.dart';
import '../components/enemies/corruption_worm.dart';
import '../components/enemies/system_core_boss.dart';
import 'package:flutter/material.dart';

enum EnemyType { sentinel, firewall, proxyTurret, corruptionWorm }
enum Formation { ring, flanks, scatter, top }

class EnemySpawn {
  final EnemyType type;
  final int count;
  final Formation formation;
  final double delay;
  bool spawned = false;

  EnemySpawn({
    required this.type,
    required this.count,
    required this.formation,
    required this.delay,
  });
}

class WaveSystem extends Component with HasGameRef<NullbyteGame> {
  int currentWaveIndex = 1;
  int sector = 1;
  
  double _timer = 0.0;
  double _waveTimer = 0.0;
  bool _waveActive = false;
  bool _waitingForNext = true;
  bool _isBossWave = false;
  
  List<EnemySpawn> _currentSpawns = [];

  late TextComponent sectorBanner;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sectorBanner = TextComponent(
      text: '',
      position: Vector2(gameRef.size.x / 2, gameRef.size.y / 2 - 100),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: gameRef.appTheme.colors.neonGreen,
          fontSize: 48,
          fontFamily: 'Rajdhani',
          fontWeight: FontWeight.bold,
          letterSpacing: 4.0,
        ),
      ),
    );
    gameRef.camera.viewport.add(sectorBanner);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (_waitingForNext) {
      _timer += dt;
      if (_timer >= 3.0) {
        _timer = 0.0;
        _startNextWave();
      }
      return;
    }

    if (_waveActive) {
      _waveTimer += dt;
      
      bool allSpawned = true;
      for (final spawn in _currentSpawns) {
        if (!spawn.spawned && _waveTimer >= spawn.delay) {
          _spawnEnemies(spawn);
          spawn.spawned = true;
        }
        if (!spawn.spawned) allSpawned = false;
      }
      
      if (allSpawned) {
        final enemies = gameRef.world.children.whereType<BaseEnemy>();
        if (enemies.isEmpty) {
          _waveActive = false;
          _waitingForNext = true;
          
          if (_isBossWave) {
             sector++;
             sectorBanner.text = "SECTOR $sector REACHED";
             gameRef.scoringSystem.addScore(5000 * sector);
          }
          currentWaveIndex++;
        }
      }
    }
  }

  void _startNextWave() {
    _waitingForNext = false;
    _waveActive = true;
    _waveTimer = 0.0;
    sectorBanner.text = ''; // Clear banner
    _currentSpawns = [];
    
    if (currentWaveIndex % 5 == 0) {
      _isBossWave = true;
      gameRef.world.add(SystemCoreBoss(initialPosition: gameRef.player.position + Vector2(0, -400)));
      return;
    }
    
    _isBossWave = false;
    final rnd = Random();
    int numSpawns = 1 + (sector / 2).floor();
    if (numSpawns > 5) numSpawns = 5;
    double currentDelay = 0.0;
    
    for (int i = 0; i < numSpawns; i++) {
      final type = EnemyType.values[rnd.nextInt(EnemyType.values.length)];
      final formation = Formation.values[rnd.nextInt(Formation.values.length)];
      final count = 1 + rnd.nextInt(3 + sector);
      
      _currentSpawns.add(EnemySpawn(
        type: type,
        count: count,
        formation: formation,
        delay: currentDelay,
      ));
      currentDelay += 2.0 + rnd.nextDouble() * 3.0;
    }
  }

  void _spawnEnemies(EnemySpawn spawn) {
    final hpMulti = 1.0 + (sector * 0.15);
    final rnd = Random();
    final playerPos = gameRef.player.position;
    
    for (int i = 0; i < spawn.count; i++) {
      Vector2 pos;
      switch (spawn.formation) {
        case Formation.ring:
          final angle = (i * 360 / spawn.count) * pi / 180.0;
          pos = playerPos + Vector2(cos(angle), sin(angle)) * 300.0;
          break;
        case Formation.flanks:
          final side = i % 2 == 0 ? -1 : 1;
          pos = playerPos + Vector2(side * 300.0, -100.0 - rnd.nextDouble() * 200);
          break;
        case Formation.scatter:
          pos = playerPos + Vector2((rnd.nextDouble() - 0.5) * 600, -300 - rnd.nextDouble() * 300);
          break;
        case Formation.top:
          pos = playerPos + Vector2((i - spawn.count / 2) * 80.0, -400.0);
          break;
      }
      
      BaseEnemy enemy;
      switch (spawn.type) {
        case EnemyType.sentinel:
          enemy = SentinelNode(orbitCenter: pos);
          break;
        case EnemyType.firewall:
          enemy = FirewallDrone(initialPosition: pos);
          break;
        case EnemyType.proxyTurret:
          enemy = ProxyTurret(initialPosition: pos);
          break;
        case EnemyType.corruptionWorm:
          enemy = CorruptionWormHead(initialPosition: pos);
          break;
      }
      
      enemy.maxHp *= hpMulti;
      enemy.hp = enemy.maxHp;
      gameRef.world.add(enemy);
    }
  }
}
