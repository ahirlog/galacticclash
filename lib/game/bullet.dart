import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';

import 'enemy.dart';

// This component represent a bullet in game world.
class Bullet extends SpriteComponent with CollisionCallbacks {
  // Speed of the bullet.
  double _speed = 450;

  Bullet({
    Sprite? sprite,
    Vector2? position,
    Vector2? size,
  }) : super(sprite: sprite, position: position, size: size);

  @override
  void onMount() {
    super.onMount();

    // Adding a circular hitbox with radius as 0.4 times
    //  the smallest dimension of this components size.
    final shape = CircleHitbox.relative(
      0.4,
      parentSize: size,
      position: size / 2,
      anchor: Anchor.center,
    );
    add(shape);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    // If the other Collidable is Enemy, remove this bullet.
    if (other is Enemy) {
      removeFromParent();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Moves the bullet to a new position with _speed.
    this.position += Vector2(0, -1) * this._speed * dt;

    // If bullet crosses the upper boundary of screen
    // mark it to be removed it from the game world.
    if (this.position.y < 0) {
      removeFromParent();
    }
  }
}
