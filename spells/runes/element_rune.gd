extends Rune
class_name ElementRune

@export var color: Color = Color(1, 1, 1)

func apply_to_projectile(projectile):
	projectile.set_element_color(color)
