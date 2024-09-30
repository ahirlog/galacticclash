import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'bullet.dart';
import 'command.dart';
import 'game.dart';
import 'knows_game_size.dart';
import 'player.dart';

// This class represent an enemy component.
class Enemy extends SpriteComponent
    with CollisionCallbacks, HasGameReference<SpacescapeGame> {
  // The speed of this enemy.
  double _speed = 250;

  Random _random = Random();

  // This direction in which this Enemy will move.
  // Defaults to vertically downwards.
  Vector2 moveDirection = Vector2(0, 1);

  // This method generates a random vector with its angle
  // between from 0 and 360 degrees.
  Vector2 getRandomVector() {
    return (Vector2.random(_random) - Vector2.random(_random)) * 500;
  }

  Enemy({
    Sprite? sprite,
    Vector2? position,
    Vector2? size,
  }) : super(sprite: sprite, position: position, size: size) {
    // Rotates the enemy component by 180 degrees. This is needed because
    // all the sprites initially face the same direct, but we want enemies to be
    // moving in opposite direction.
    angle = pi;
  }

  @override
  void onMount() {
    super.onMount();

    // Adding a circular hitbox with radius as 0.8 times
    // the smallest dimension of this components size.
    final shape = CircleHitbox.relative(
      0.8,
      parentSize: size,
      position: size / 2,
      anchor: Anchor.center,
    );
    add(shape);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    // If the other Collidable is a Bullet, remove this Enemy.
    if (other is Bullet || other is Player) {
      destroy();
    }
  }

  // This method will destory this enemy.
  void destroy() {
    removeFromParent();

    // Before dying, register a command to increase
    // player's score by 1.
    final command = Command<Player>(action: (player) {
      player.addToScore(1);
    });
    game.addCommand(command);

    // Generate 20 white circle particles with random speed and acceleration,
    // at current position of this enemy. Each particles lives for exactly
    // 0.1 seconds and will get removed from the game world after that.
    final particleComponent = ParticleSystemComponent(
      particle: Particle.generate(
        count: 20,
        lifespan: 0.1,
        generator: (i) => AcceleratedParticle(
          acceleration: getRandomVector(),
          speed: getRandomVector(),
          position: position.clone(),
          child: CircleParticle(
            radius: 2,
            paint: Paint()..color = Colors.white,
          ),
        ),
      ),
    );

    game.add(particleComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update the position of this enemy using its speed and delta time.
    position += moveDirection * _speed * dt;

    // If the enemy leaves the screen, destroy it.
    if (position.y > game.fixedResolution.y) {
      removeFromParent();
    } else if ((position.x < size.x / 2) ||
        (position.x > (game.fixedResolution.x - size.x / 2))) {
      // Enemy is going outside vertical screen bounds, flip its x direction.
      moveDirection.x *= -1;
    }
  }
}
