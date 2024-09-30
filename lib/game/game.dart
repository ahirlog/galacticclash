import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:galacticclash/game/bullet.dart';
import 'package:galacticclash/game/command.dart';
import 'package:galacticclash/game/enemy.dart';
import 'package:galacticclash/game/enemy_manager.dart';
import 'package:galacticclash/game/knows_game_size.dart';
import 'player.dart';

// This class is responsible for initializing and running the game-loop.
class SpacescapeGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  // Stores a reference to player component.
  late Player _player;

  // Stores a reference to the main spritesheet.
  late SpriteSheet spriteSheet;

  // Stores a reference to an enemy manager component.
  late EnemyManager _enemyManager;

  // Displays player score on top left.
  late TextComponent _playerScore;

  // Displays player helth on top right.
  late TextComponent _playerHealth;

  // List of commands to be processed in current update.
  final _commandList = List<Command>.empty(growable: true);

  // List of commands to be processed in next update.
  final _addLaterCommandList = List<Command>.empty(growable: true);

  // Indicates wheater the game world has been already initilized.
  bool _isAlreadyLoaded = false;

  // Returns the size of the playable area of the game window.
  Vector2 fixedResolution = Vector2(540, 960);

  late CameraComponent primaryCamera;

  // This method gets called by Flame before the game-loop begins.
  // Assets loading and adding component should be done here.
  @override
  Future<void> onLoad() async {
    // Initilize the game world only one time.
    if (!_isAlreadyLoaded) {
      // Loads and caches the image for later use.
      await images.load('simpleSpace_tilesheet.png');

      spriteSheet = SpriteSheet.fromColumnsAndRows(
        image: images.fromCache('simpleSpace_tilesheet.png'),
        columns: 8,
        rows: 6,
      );

      // final spaceship = Spaceship(
      //   name: 'Dusky',
      //   cost: 100,
      //   speed: 400,
      //   spriteId: 1,
      //   assetPath: 'assets/images/ship_B.png',
      //   level: 2,
      // );

      _player = Player(
        sprite: spriteSheet.getSpriteById(1),
        size: Vector2(64, 64),
        position: fixedResolution / 2,
      );

      // Makes sure that the sprite is centered.
      _player.anchor = Anchor.center;
      add(_player);

      _enemyManager = EnemyManager(spriteSheet: spriteSheet);
      add(_enemyManager);

      // Create a basic joystick component on left.
      final joystick = JoystickComponent(
        anchor: Anchor.bottomLeft,
        position: Vector2(30, fixedResolution.y - 30),
        // size: 100,
        background: CircleComponent(
          radius: 60,
          paint: Paint()..color = Colors.white.withOpacity(0.5),
        ),
        knob: CircleComponent(radius: 30),
      );

      primaryCamera = CameraComponent.withFixedResolution(
        world: world,
        width: fixedResolution.x,
        height: fixedResolution.y,
        hudComponents: [joystick],
      )..viewfinder.position = fixedResolution / 2;
      await add(primaryCamera);

      // Create text component for player score.
      _playerScore = TextComponent(
        text: 'Score: 0',
        position: Vector2(10, 10),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'BungeeInline',
          ),
        ),
      );

      // Create text component for player health.
      _playerHealth = TextComponent(
        text: 'Health: 100%',
        position: Vector2(fixedResolution.x - 10, 10),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'BungeeInline',
          ),
        ),
      );

      // Anchor to top right as we want the top right
      // corner of this component to be at a specific position.
      _playerHealth.anchor = Anchor.topRight;

      add(_playerHealth);

      // Set this to true so that we do not initilize
      // everything again in the same session.
      _isAlreadyLoaded = true;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Run each command from _commandList on each
    // component from components list. The run()
    // method of Command is no-op if the command is
    // not valid for given component.
    for (var command in _commandList) {
      for (var component in world.children) {
        command.run(component);
      }
    }

    // Remove all the commands that are processed and
    // add all new commands to be processed in next update.
    _commandList.clear();
    _commandList.addAll(_addLaterCommandList);
    _addLaterCommandList.clear();

    // Update score and health components with latest values.
    _playerScore.text = 'Score: ${_player.score}';
    _playerHealth.text = 'Health: ${_player.health}%';
  }

  @override
  void render(Canvas canvas) {
    // Draws a rectangular health bar at top right corner.
    canvas.drawRect(
      Rect.fromLTWH(size.x - 110, 10, _player.health.toDouble(), 20),
      Paint()..color = Colors.blue,
    );

    super.render(canvas);
  }

  // Adds given command to command list.
  void addCommand(Command command) {
    _addLaterCommandList.add(command);
  }

  // Resets the game to inital state. Should be called
  // while restarting and exiting the game.
  void reset() {
    // First reset player and enemy manager.
    // _player.reset();
    _enemyManager.reset();

    // Now remove all the enemies and bullets from
    // game world. Note that, we are not calling
    // Enemy.destroy() because it will unnecessarily
    // run explosion effect and increase players score.
    world.children.whereType<Enemy>().forEach((enemy) {
      enemy.removeFromParent();
    });

    world.children.whereType<Bullet>().forEach((bullet) {
      bullet.removeFromParent();
    });
  }
}
