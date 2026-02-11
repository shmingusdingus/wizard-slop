extends Rune
class_name MotionRune

func apply_to_projectile(proj: SpellProjectile):
	super(proj)
	proj.motion_rune = self

func update_position(proj: SpellProjectile, delta: float) -> Vector3:
	return proj.direction * proj.speed * delta
