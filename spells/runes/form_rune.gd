extends Rune
class_name FormRune

@export var projectile_scene: PackedScene
@export var base_speed: float = 10.0

func apply_to_projectile(projectile):
	projectile.set_speed(base_speed)
