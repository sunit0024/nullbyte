import 'dart:ui';
import 'package:flutter/material.dart';
import '../game/nullbyte_game.dart';
import '../core/save_manager.dart';

class GameOverOverlay extends StatelessWidget {
  final NullbyteGame game;

  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final colors = game.appTheme.colors;
    final score = game.scoringSystem.score;
    final highScore = SaveManager.getHighScore();

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: colors.panelBg.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colors.neonRed.withValues(alpha: 0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.neonRed.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SYSTEM FAILURE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: colors.neonRed,
                    letterSpacing: 4.0,
                    shadows: [
                      Shadow(
                        color: colors.neonRed,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'SCORE: $score',
                  style: TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: game.appTheme.isDark ? Colors.white : Colors.black87,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'HIGH SCORE: $highScore',
                  style: TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: colors.neonCyan,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 40),
                _NeonButton(
                  text: 'REBOOT SEQUENCE',
                  color: colors.neonCyan,
                  onTap: () {
                    game.overlays.remove('GameOver');
                    game.startGame();
                  },
                ),
                const SizedBox(height: 20),
                _NeonButton(
                  text: 'MAIN MENU',
                  color: colors.neonMagenta,
                  onTap: () {
                    game.overlays.remove('GameOver');
                    game.overlays.add('MainMenu');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NeonButton extends StatefulWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;

  const _NeonButton({
    required this.text,
    required this.color,
    required this.onTap,
  });

  @override
  State<_NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<_NeonButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isHovered ? widget.color.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHovered ? widget.color : widget.color.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isHovered ? Colors.white : widget.color,
                letterSpacing: 2.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
