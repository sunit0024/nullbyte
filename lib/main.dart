import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/save_manager.dart';
import 'game/nullbyte_game.dart';
import 'ui/main_menu_overlay.dart';

import 'ui/game_over_overlay.dart';

import 'ui/settings_overlay.dart';

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

class NullbyteApp extends StatefulWidget {
  const NullbyteApp({super.key});

  @override
  State<NullbyteApp> createState() => _NullbyteAppState();
}

class _NullbyteAppState extends State<NullbyteApp> {
  late NullbyteGame _game;
  final GlobalKey _gameWidgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Create the game instance once so it doesn't restart on theme changes
    final appTheme = context.read<AppTheme>();
    _game = NullbyteGame(appTheme: appTheme);
  }

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
          key: _gameWidgetKey,
          game: _game,
          overlayBuilderMap: {
            'MainMenu': (context, game) => MainMenuOverlay(game),
            'GameOver': (context, game) => GameOverOverlay(game: game),
            'Settings': (context, game) => SettingsOverlay(game: game),
          },
        ),
      ),
    );
  }
}
