extends Rune
class_name MotionRune

@export var speed_multiplier: float = 1.0

func apply_to_projectile(proj: SpellProjectile):
	proj.motion_rune = self

func update_position(proj: SpellProjectile, delta: float) -> Vector3:
	return proj.direction * proj.speed * speed_multiplier * delta
