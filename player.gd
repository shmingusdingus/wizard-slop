extends CharacterBody3D

# Emitted when the player was hit by a mob.
# Put this at the top of the script.
signal hit

# How fast the player moves in meters per second.
@export var speed = 14
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75
# Vertical impulse applied to the character upon jumping in meters per second.
@export var jump_impulse = 20
# Vertical impulse applied to the character upon bouncing over a mob in
# meters per second.
@export var bounce_impulse = 16
var target_velocity = Vector3.ZERO

@onready var rune_label: Label3D = $RuneLabel

# Loaded rune resources
const RUNE_FIRE := preload("res://spells/runes/elements/element_fire.tres")
const RUNE_ICE := preload("res://spells/runes/elements/element_ice.tres")

const RUNE_BALL := preload("res://spells/runes/forms/form_ball.tres")
const RUNE_BEAM := preload("res://spells/runes/forms/form_beam.tres")

const RUNE_STRAIGHT := preload("res://spells/runes/motions/motion_straight.tres")

const BALL_PROJECTILE := preload("res://spells/projectiles/ball/ball_projectile.tscn")
const BEAM_PROJECTILE := preload("res://spells/projectiles/beam/beam_projectile.tscn")

# Current spell state (grammar-enforced)
var element: ElementRune = null
var form: FormRune = null
var motion: MotionRune = null

func _ready():
	_update_label()

func _unhandled_input(event):
	if event.is_action_pressed("rune_element_fire"):
		_try_add_rune(RUNE_FIRE)
	elif event.is_action_pressed("rune_element_ice"):
		_try_add_rune(RUNE_ICE)
	elif event.is_action_pressed("rune_form_ball"):
		_try_add_rune(RUNE_BALL)
	elif event.is_action_pressed("rune_form_beam"):
		_try_add_rune(RUNE_BEAM)
	elif event.is_action_pressed("rune_motion"):
		_try_add_rune(RUNE_STRAIGHT)
	elif event.is_action_pressed("rune_cast"):
		_cast_spell()

func _try_add_rune(rune: Rune) -> void:
	if rune is ElementRune and element == null:
		element = rune
	elif rune is FormRune and form == null:
		form = rune
	elif rune is MotionRune and motion == null:
		motion = rune

	_update_label()

func _update_label():
	var parts: Array[String] = []

	if element:
		parts.append(element.display_name)
	if form:
		parts.append(form.display_name)
	if motion:
		parts.append(motion.display_name)

	rune_label.text = " ".join(parts)

func _is_spell_complete() -> bool:
	return element != null and form != null and motion != null

func _has_any_runes() -> bool:
	return element != null or form != null or motion != null

func _cast_spell():
	if not _has_any_runes():
		print("No runes entered")
		return

	if not _is_spell_complete():
		print("Incomplete spell")
		await _fizzle_spell()
		return

	_spawn_spell_projectile()
	await _success_pulse()
	_clear_spell()

func _spawn_spell_projectile():
	# You can replace this with your runtime spell system
	if not form or not form.projectile_scene:
		print("No projectile scene assigned for form")
		return

	var forward_dir: Vector3 = (-$Pivot.global_transform.basis.z).normalized()
	var spell = Spell.new(element, form, motion)
	var spell_proj = form.projectile_scene.instantiate()
	spell_proj.initialize(spell)
	spell_proj.set_direction(forward_dir)
	
	spell_proj.global_transform.origin = global_transform.origin + forward_dir
	get_parent().add_child(spell_proj)
	spell_proj.global_transform = $Pivot.global_transform

	#or this:	get_tree().current_scene.add_child(spell_proj)

func _fizzle_spell():
	await _fizzle_pulse()
	_clear_spell()

func _clear_spell():
	element = null
	form = null
	motion = null
	_update_label()

func _fizzle_pulse() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	var original_scale := rune_label.scale
	var shrink_scale := original_scale * 0.85

	var original_modulate := rune_label.modulate
	var fizzle_color := Color(0.6, 0.6, 0.6, 1.0)

	tween.tween_property(rune_label, "scale", shrink_scale, 0.08)
	tween.parallel().tween_property(rune_label, "modulate", fizzle_color, 0.08)

	tween.tween_property(rune_label, "scale", original_scale, 0.08)
	tween.parallel().tween_property(rune_label, "modulate", original_modulate, 0.08)

	await tween.finished

func _success_pulse() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	var original_scale := rune_label.scale
	var pulse_scale := original_scale * 1.3

	tween.tween_property(rune_label, "scale", pulse_scale, 0.1)
	tween.tween_property(rune_label, "scale", original_scale, 0.1)

	await tween.finished

func _physics_process(delta):
	# We create a local variable to store the input direction.
	var direction = Vector3.ZERO

	# We check for each move input and update the direction accordingly.
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		# Notice how we are working with the vector's x and z axes.
		# In 3D, the XZ plane is the ground plane.
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		# Setting the basis property will affect the rotation of the node.
		$Pivot.basis = Basis.looking_at(direction)
		if is_on_floor():
			$AnimationPlayer.speed_scale = 4
	else:
		$AnimationPlayer.speed_scale = 1

	# Ground Velocity
	if speed:
		target_velocity.x = direction.x * speed
		target_velocity.z = direction.z * speed

	# Vertical Velocity
	if not is_on_floor() and delta: # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	# Jumping.
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		target_velocity.y = jump_impulse
		$AnimationPlayer.speed_scale = 1

	# Iterate through all collisions that occurred this frame
	for index in range(get_slide_collision_count()):
		# We get one of the collisions with the player
		var collision = get_slide_collision(index)

		# If there are duplicate collisions with a mob in a single frame
		# the mob will be deleted after the first collision, and a second call to
		# get_collider will return null, leading to a null pointer when calling
		# collision.get_collider().is_in_group("mob").
		# This block of code prevents processing duplicate collisions.
		if collision.get_collider() == null:
			continue

		# If the collider is with a mob
		if collision.get_collider().is_in_group("mob"):
			var mob = collision.get_collider()
			# we check that we are hitting it from above.
			#print(Vector3.UP.dot(collision.get_normal()))
			if Vector3.UP.dot(collision.get_normal()) > 0.7:
				# If so, we squash it and bounce.
				mob.squash()
				target_velocity.y = bounce_impulse
				# Prevent further duplicate calls.
				break

	# Moving the Character
	velocity = target_velocity
	move_and_slide()
	$Pivot.rotation.x = PI / 6 * velocity.y / jump_impulse

# And this function at the bottom.
func die():
	hit.emit()
	queue_free()

func _on_mob_detector_body_entered(_body: Node3D) -> void:
	die()
