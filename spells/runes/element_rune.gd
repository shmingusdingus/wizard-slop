extends Rune
class_name ElementRune

@export var color: Color = Color(1, 1, 1)

func apply_to_projectile(proj: SpellProjectile):
	super(proj)
	proj.set_element_color(color)
