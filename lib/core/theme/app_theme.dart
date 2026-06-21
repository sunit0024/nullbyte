import 'package:flutter/material.dart';

class AppTheme extends ChangeNotifier {
  bool _isDark = true;
  bool get isDark => _isDark;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  void setTheme(bool isDark) {
    _isDark = isDark;
    notifyListeners();
  }

  NullbyteColors get colors => _isDark ? NullbyteColors.dark() : NullbyteColors.light();
}

class NullbyteColors {
  final Color background;
  final Color grid;
  final Color neonCyan;
  final Color neonMagenta;
  final Color neonAmber;
  final Color neonGreen;
  final Color neonRed;
  final Color panelBg;
  final Color panelBorder;
  final Color textPrimary;
  final Color textSecondary;

  NullbyteColors({
    required this.background,
    required this.grid,
    required this.neonCyan,
    required this.neonMagenta,
    required this.neonAmber,
    required this.neonGreen,
    required this.neonRed,
    required this.panelBg,
    required this.panelBorder,
    required this.textPrimary,
    required this.textSecondary,
  });

  factory NullbyteColors.dark() {
    return NullbyteColors(
      background: const Color(0xFF050510),
      grid: const Color(0xFF1B1B3A),
      neonCyan: const Color(0xFF00F5FF),
      neonMagenta: const Color(0xFFFF00FF),
      neonAmber: const Color(0xFFFFB300),
      neonGreen: const Color(0xFF00FF88),
      neonRed: const Color(0xFFFF2244),
      panelBg: const Color(0xFF0A0A1E).withOpacity(0.85),
      panelBorder: const Color(0xFF00F5FF).withOpacity(0.40),
      textPrimary: const Color(0xFFE8F4FF),
      textSecondary: const Color(0xFF7A8EAA),
    );
  }

  factory NullbyteColors.light() {
    return NullbyteColors(
      background: const Color(0xFFF0F4FF),
      grid: const Color(0xFFCDD6F0),
      neonCyan: const Color(0xFF006EFF), // deep electric blue
      neonMagenta: const Color(0xFFCC00CC),
      neonAmber: const Color(0xFFD48000), // dark gold
      neonGreen: const Color(0xFF007A44),
      neonRed: const Color(0xFFCC1133),
      panelBg: const Color(0xFFFFFFFF).withOpacity(0.90),
      panelBorder: const Color(0xFF006EFF).withOpacity(0.50),
      textPrimary: const Color(0xFF0A0A2E),
      textSecondary: const Color(0xFF4A5580),
    );
  }
}
