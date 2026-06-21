class Constants {
  // Player
  static const double playerBaseSpeed = 220.0;
  static const double playerBoostSpeed = 350.0;
  static const double playerSize = 48.0;

  // Enemies
  static const double sentinelSpeed = 60.0;
  static const double sentinelHp = 30.0;
  
  static const double firewallSpeed = 340.0;
  static const double firewallHp = 20.0;

  static const double proxyTurretHp = 60.0;
  static const double corruptionWormHp = 80.0;
  static const double corruptionWormSpeed = 90.0;

  // Pools
  static const int playerBulletPoolSize = 150;
  static const int enemyBulletPoolSize = 300;
  static const int particlePoolSize = 300;
  static const int hitSparkPoolSize = 100;
  static const int pickupPoolSize = 20;

  // Layout
  static const double joystickSize = 100.0;
}

enum WeaponType { hexblast, dataLance, nullScatter }
