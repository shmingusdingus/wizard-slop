extends Rune
class_name FormRune

@export var projectile_scene: PackedScene

func apply_to_projectile(proj: SpellProjectile):
	super(proj)
