import 'dart:ui';
import 'package:flame/components.dart';

abstract class PooledBullet {
  bool _isActive = false;
  bool get isActive => _isActive;
  
  bool get isExpired;

  void activate() {
    _isActive = true;
  }

  void deactivate() {
    _isActive = false;
  }

  void updateBullet(double dt);
  void renderBullet(Canvas canvas);
}

class BulletPool<T extends PooledBullet> {
  final List<T> _available = [];
  final List<T> _active = [];
  final T Function() _factory;
  final int _initialSize;

  List<T> get activeBullets => _active;

  BulletPool({required T Function() factory, int initialSize = 100})
      : _factory = factory, _initialSize = initialSize {
    _prewarm();
  }

  void _prewarm() {
    for (int i = 0; i < _initialSize; i++) {
      final bullet = _factory();
      bullet.deactivate();
      _available.add(bullet);
    }
  }

  T acquire() {
    if (_available.isEmpty) {
      for (int i = 0; i < 20; i++) {
        _available.add(_factory()..deactivate());
      }
    }
    final bullet = _available.removeLast();
    _active.add(bullet);
    bullet.activate();
    return bullet;
  }

  void release(T bullet) {
    _active.remove(bullet);
    bullet.deactivate();
    _available.add(bullet);
  }

  void updateAll(double dt) {
    for (int i = _active.length - 1; i >= 0; i--) {
      final b = _active[i];
      b.updateBullet(dt);
      if (b.isExpired) {
        release(b);
      }
    }
  }

  void renderAll(Canvas canvas) {
    for (final b in _active) {
      b.renderBullet(canvas);
    }
  }
}

class BulletPoolComponent<T extends PooledBullet> extends Component {
  final BulletPool<T> pool;

  BulletPoolComponent({required this.pool});

  @override
  void update(double dt) {
    pool.updateAll(dt);
  }

  @override
  void render(Canvas canvas) {
    pool.renderAll(canvas);
  }
}
