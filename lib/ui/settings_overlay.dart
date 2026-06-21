import 'dart:ui';
import 'package:flutter/material.dart';
import '../game/nullbyte_game.dart';

class SettingsOverlay extends StatelessWidget {
  final NullbyteGame game;

  const SettingsOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final colors = game.appTheme.colors;
    final isDark = game.appTheme.isDark;

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: colors.panelBg.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colors.neonCyan.withValues(alpha: 0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.neonCyan.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SETTINGS',
                  style: TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: colors.neonCyan,
                    letterSpacing: 4.0,
                    shadows: [
                      Shadow(
                        color: colors.neonCyan,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                
                // Theme Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'THEME',
                      style: TextStyle(
                        fontFamily: 'Rajdhani',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                        letterSpacing: 2.0,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        game.appTheme.toggleTheme();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: colors.neonMagenta.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colors.neonMagenta,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          isDark ? 'DARK 🌙' : 'LIGHT ☀️',
                          style: TextStyle(
                            fontFamily: 'Rajdhani',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : colors.neonMagenta,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Sound Placeholder
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SOUND',
                      style: TextStyle(
                        fontFamily: 'Rajdhani',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                        letterSpacing: 2.0,
                      ),
                    ),
                    Text(
                      'COMING SOON',
                      style: TextStyle(
                        fontFamily: 'Rajdhani',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 50),
                
                _NeonButton(
                  text: 'RESUME',
                  color: colors.neonGreen,
                  onTap: () {
                    game.overlays.remove('Settings');
                    game.gamePaused = false;
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
