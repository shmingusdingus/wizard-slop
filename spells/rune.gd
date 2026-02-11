extends Resource
class_name Rune

@export var id: String
@export var display_name: String
@export var icon: Texture2D

@export var damage_modifier: float = 1.0
@export var speed_modifier: float = 1.0

func apply_to_projectile(proj: SpellProjectile):
	proj.set_damage(damage_modifier)
	proj.set_speed(speed_modifier)
