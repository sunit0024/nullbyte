import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/nullbyte_game.dart';
import '../core/theme/app_theme.dart';
import '../core/save_manager.dart';

class MainMenuOverlay extends StatelessWidget {
  final NullbyteGame game;
  
  const MainMenuOverlay(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    
    return Material(
      color: appTheme.colors.background.withValues(alpha: 0.9),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'NULLBYTE',
                  style: TextStyle(
                    color: appTheme.colors.neonCyan,
                    fontSize: 80,
                    fontFamily: 'Rajdhani',
                    fontWeight: FontWeight.bold,
                    letterSpacing: 10,
                    shadows: [
                      Shadow(color: appTheme.colors.neonCyan, blurRadius: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'HIGH SCORE: ${SaveManager.getHighScore()}',
                  style: TextStyle(
                    color: appTheme.colors.neonAmber,
                    fontSize: 24,
                    fontFamily: 'Rajdhani',
                  ),
                ),
                Text(
                  'MAX SECTOR: ${SaveManager.getMaxSector()}',
                  style: TextStyle(
                    color: appTheme.colors.neonAmber,
                    fontSize: 20,
                    fontFamily: 'Rajdhani',
                  ),
                ),
                const SizedBox(height: 50),
                _buildButton('START HACK', appTheme.colors.neonGreen, () {
                  game.overlays.remove('MainMenu');
                  game.startGame();
                }),
                const SizedBox(height: 20),
                _buildButton('SETTINGS', appTheme.colors.neonAmber, () {
                  game.overlays.add('Settings');
                }),
              ],
            ),
          ),
          Positioned(
            top: 40,
            right: 40,
            child: GestureDetector(
              onTap: () {
                appTheme.toggleTheme();
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: appTheme.colors.panelBg.withValues(alpha: 0.85),
                  border: Border.all(
                    color: appTheme.colors.neonMagenta.withValues(alpha: 0.7),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: appTheme.colors.neonMagenta.withValues(alpha: 0.2),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  appTheme.isDark ? "🌙" : "☀️",
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 10, spreadRadius: 2),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontFamily: 'Rajdhani',
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
