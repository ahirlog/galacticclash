import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
// import 'package:flutter/material.dart';

// This class is responsible for initializing and running the game-loop.
class SpaceScapeGame extends FlameGame {
  // Returns the size of the playable area of the game window.
  Vector2 fixedResolution = Vector2(540, 960);

  // This method gets called by Flame before the game-loop begins.
  // Assets loading and adding component should be done here.
  @override
  Future<void> onLoad() async {
    await images.load('simpleSpace_tilesheet.png');

    final spriteSheet = SpriteSheet.fromColumnsAndRows(
      image: images.fromCache('simpleSpace_tilesheet.png'),
      columns: 8,
      rows: 6,
    );

    SpriteComponent player = SpriteComponent(
      sprite: spriteSheet.getSpriteById(19),
      size: Vector2(64, 64),
      position: fixedResolution / 2,
    );

    // Makes sure that the sprite is centered.
    player.anchor = Anchor.topRight;

    add(player);
  }
}
