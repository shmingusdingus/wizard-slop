extends Rune
class_name FormRune

@export var projectile_scene: PackedScene
@export var base_speed: float = 10.0

func apply_to_projectile(proj: SpellProjectile):
	proj.set_speed(base_speed)
