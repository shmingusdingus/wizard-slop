extends Rune
class_name MotionRune

@export var velocity: Vector3 = Vector3.FORWARD

func apply_to_projectile(proj: SpellProjectile):
	proj.set_velocity(proj.direction)
