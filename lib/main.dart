import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/save_manager.dart';
import 'game/nullbyte_game.dart';
import 'ui/main_menu_overlay.dart';

import 'ui/game_over_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SaveManager.init();
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppTheme(),
      child: const NullbyteApp(),
    ),
  );
}

class NullbyteApp extends StatelessWidget {
  const NullbyteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    
    return MaterialApp(
      title: 'NULLBYTE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: appTheme.isDark ? Brightness.dark : Brightness.light,
        fontFamily: 'Rajdhani',
      ),
      home: Scaffold(
        body: GameWidget<NullbyteGame>(
          game: NullbyteGame(appTheme: appTheme),
          overlayBuilderMap: {
            'MainMenu': (context, game) => MainMenuOverlay(game),
            'GameOver': (context, game) => GameOverOverlay(game: game),
          },
          initialActiveOverlays: const ['MainMenu'],
        ),
      ),
    );
  }
}
