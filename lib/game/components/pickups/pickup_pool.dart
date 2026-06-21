import 'dart:ui';
import 'package:flame/components.dart';
import '../../../core/theme/app_theme.dart';
import '../../../game/nullbyte_game.dart';

enum PickupType { health, shield, weapon, dataShard }

abstract class PooledPickup {
  bool _isActive = false;
  bool get isActive => _isActive;
  
  Vector2 position = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  
  PickupType type = PickupType.dataShard;
  
  double _lifetime = 10.0;
  double _elapsed = 0.0;

  bool get isExpired => _elapsed >= _lifetime;

  void activate(Vector2 pos, PickupType pType) {
    _isActive = true;
    position.setFrom(pos);
    type = pType;
    _elapsed = 0.0;
    
    // Slight upward drift and then fall? Or just float slowly towards player?
    // Let's just have them float downwards slowly.
    velocity = Vector2(0, 30.0);
  }

  void deactivate() {
    _isActive = false;
  }

  void updatePickup(double dt) {
    _elapsed += dt;
    position += velocity * dt;
  }

  void renderPickup(Canvas canvas, AppTheme appTheme);
}

class PickupPool {
  final List<PooledPickup> _available = [];
  final List<PooledPickup> _active = [];
  final PooledPickup Function() _factory;
  final int _initialSize;

  List<PooledPickup> get activePickups => _active;

  PickupPool({required PooledPickup Function() factory, int initialSize = 20})
      : _factory = factory, _initialSize = initialSize {
    _prewarm();
  }

  void _prewarm() {
    for (int i = 0; i < _initialSize; i++) {
      final pickup = _factory();
      pickup.deactivate();
      _available.add(pickup);
    }
  }

  PooledPickup acquire(Vector2 pos, PickupType type) {
    if (_available.isEmpty) {
      for (int i = 0; i < 5; i++) {
        _available.add(_factory()..deactivate());
      }
    }
    final pickup = _available.removeLast();
    _active.add(pickup);
    pickup.activate(pos, type);
    return pickup;
  }

  void release(PooledPickup pickup) {
    _active.remove(pickup);
    pickup.deactivate();
    _available.add(pickup);
  }

  void updateAll(double dt) {
    for (int i = _active.length - 1; i >= 0; i--) {
      final p = _active[i];
      p.updatePickup(dt);
      if (p.isExpired) {
        release(p);
      }
    }
  }

  void renderAll(Canvas canvas, AppTheme appTheme) {
    for (final p in _active) {
      p.renderPickup(canvas, appTheme);
    }
  }
}

class PickupPoolComponent extends Component with HasGameRef<NullbyteGame> {
  final PickupPool pool;
  final AppTheme appTheme;

  PickupPoolComponent({required this.pool, required this.appTheme});

  @override
  void update(double dt) {
    if (gameRef.gamePaused) return;
    pool.updateAll(dt);
  }

  @override
  void render(Canvas canvas) {
    pool.renderAll(canvas, appTheme);
  }
}
