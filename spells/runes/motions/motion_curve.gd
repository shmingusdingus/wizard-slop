extends MotionRune
class_name MotionRuneCurve

# Positive = Right, Negative = Left
@export var curve_intensity: float = 15.0
@export var use_logarithmic: bool = true

func update_position(proj: SpellProjectile, delta: float) -> Vector3:
	var forward = proj.direction * proj.speed * delta

	var curve_factor: float
	if use_logarithmic:
		# Ends up being a gentle "L" shape
		curve_factor = log(proj.lifetime + 1.0) * curve_intensity
	else:
		# Ends up being a spiral or sharp hook
		curve_factor = (proj.lifetime ** 2) * curve_intensity

	var side_dir = proj.spawn_basis.x

	#var local_right = proj.global_transform.basis.x
	#var lateral_movement = local_right * curve_factor * delta
	return forward + (side_dir * curve_factor * delta)
