extends Resource
class_name Spell

var element: ElementRune
var form: FormRune
var motion: MotionRune

func _init(_element: ElementRune = null, _form: FormRune = null, _motion: MotionRune = null):
	element = _element
	form = _form
	motion = _motion

func apply_to_projectile(proj: SpellProjectile):
	if element:
		element.apply_to_projectile(proj)
	if form:
		form.apply_to_projectile(proj)
	if motion:
		motion.apply_to_projectile(proj)
