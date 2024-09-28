import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:galacticclash/game/game.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // This opens the app in fullscreen mode.
  await Flame.device.fullScreen();

  runApp(
    GameWidget(
      game: SpaceScapeGame(),
    ),
  );
}
