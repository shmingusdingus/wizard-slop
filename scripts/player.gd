extends CharacterBody3D

@export var health: float = 100.0:
	set(value):
		health = value
		_update_health_ui()
# How fast the player moves in meters per second.
@export var speed = 14
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75
# Vertical impulse applied to the character upon jumping in meters per second.
@export var jump_impulse = 20
# Vertical impulse applied to the character upon bouncing over a mob in
# meters per second.
@export var bounce_impulse = 16
# is_on_floor() boolean exported for use in multiplayerspawner replication
@export var sync_on_floor := true
# player velocity vector exported for use in multiplayerspawner replication
@export var sync_velocity := Vector3.ZERO
var target_velocity = Vector3.ZERO
var casting: bool = false


@onready var sprite := $Pivot/AnimatedSprite3D
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

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready():
	var animated_sprite = $Pivot/AnimatedSprite3D
	print("sprite height: " + str(animated_sprite.sprite_frames.get_frame_texture("idle_forward",0).get_height()) + "  sprite width: "+ str(animated_sprite.sprite_frames.get_frame_texture("idle_forward",0).get_width()))
	$StatusSynchronizer.set_multiplayer_authority(1)
	_update_health_ui()
	sprite.play("idle_forward")
	_update_label()

func _unhandled_input(event):
	if !is_multiplayer_authority(): return
	
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
		if not casting:
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

	casting = true

	var e_path = element.resource_path
	var f_path = form.resource_path
	var m_path = motion.resource_path

	request_spell_spawn.rpc_id(1, e_path, f_path, m_path)

	await _success_pulse()
	_clear_spell()

@rpc("any_peer", "call_local", "reliable")
func request_spell_spawn(e_path: String, f_path: String, m_path: String):
	if not multiplayer.is_server(): return
	
	var pivot = $Pivot
	var forward_dir: Vector3 = (-pivot.global_transform.basis.z).normalized()
	
	var spawn_transform = pivot.global_transform
	spawn_transform.origin = pivot.global_position + (forward_dir * 1.5)
	
	var data = {
		"e": e_path,
		"f": f_path,
		"m": m_path,
		"dir": forward_dir,
		"trans": spawn_transform
	}

	var spawner = get_tree().get_first_node_in_group("projectile_spawner")
	spawner.spawn(data)

func _fizzle_spell():
	await _fizzle_pulse()
	_clear_spell()

func _clear_spell():
	element = null
	form = null
	motion = null
	_update_label()
	casting = false

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
	if !is_multiplayer_authority(): return

	var input_dir = Vector3.ZERO
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_back"):
		input_dir.z += 1
	if Input.is_action_pressed("move_forward"):
		input_dir.z -= 1
	# TRANSFORM the input direction based on the player's current rotation
	# This makes 'forward' always follow the direction the player is facing.
	var direction = (transform.basis * input_dir).normalized()

	if input_dir != Vector3.ZERO:
		$Pivot.basis = Basis.looking_at(input_dir.normalized())
	else:
		$Pivot.basis = Basis.looking_at(Vector3.FORWARD)

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

	velocity = target_velocity

	# Sync replication variables
	# Should be here or before new velocity is set?
	# Maybe after move_and_slide()? idk
	sync_on_floor = is_on_floor()
	sync_velocity = velocity

	move_and_slide()
	$Pivot.rotation.x = PI / 6 * velocity.y / jump_impulse

func _process(_delta):
	update_sprite_visuals()

func update_sprite_visuals():
	var anim_base = ""
	var horizontal_vel = Vector3(sync_velocity.x, 0, sync_velocity.z)
	
	# 1. Determine Base State
	if not sync_on_floor:
		anim_base = "jump"
	elif horizontal_vel.length() > 0.05:
		anim_base = "walk"
	else:
		anim_base = "idle"

	# 2. Determine Directional Suffix
	var suffix = calculate_direction_suffix()
	var final_anim = anim_base + suffix

	# 3. Apply Animation
	if sprite.animation != final_anim:
		# Safety check to ensure the animation exists in the SpriteFrames
		if sprite.sprite_frames.has_animation(final_anim):
			# If transitioning between directions of the same action (like jumping),
			# keep the current frame so the animation doesn't "restart"
			if "jumping" in sprite.animation and "jumping" in final_anim:
				var current_frame = sprite.frame
				sprite.animation = final_anim
				sprite.frame = current_frame
			else:
				sprite.animation = final_anim
				sprite.play()

func calculate_direction_suffix() -> String:
	var cam = get_viewport().get_camera_3d()
	if not cam: return "_forward"

	# Get Camera Forward (flat on XZ plane)
	var cam_forward = -cam.global_transform.basis.z
	cam_forward.y = 0
	cam_forward = cam_forward.normalized()

	# Get Player Forward (Using the synced Pivot rotation)
	var player_forward = -$Pivot.global_transform.basis.z 
	player_forward.y = 0
	player_forward = player_forward.normalized()

	var dot = cam_forward.dot(player_forward)
	var cross = cam_forward.cross(player_forward).y

	# Mapping: Forward = Facing away, Back = Facing camera
	if dot > 0.45:
		return "_forward" # Aligned with camera (looking away)
	elif dot < -0.45:
		return "_back"    # Opposite of camera (looking at us)
	else:
		# Use cross product for Left vs Right
		if cross > 0:
			return "_left"
		else:
			return "_right"

func take_damage(amount: float):
	if not multiplayer.is_server():
		return

	health -= amount
	#print("Player hit! Health remaining: ", health)
	
	_update_health_ui()
	
	if health <= 0:
		_die_on_server()

func _update_health_ui():
	if has_node("StatusBarAnchor/Sprite3D/SubViewport/HealthBar"):
		$StatusBarAnchor/Sprite3D/SubViewport/HealthBar.value = health

func _die_on_server():
	var dead_player_id = get_multiplayer_authority()
	notify_client_death.rpc_id(dead_player_id)
	print("Player ", dead_player_id, " has died.")
	get_tree().create_timer(10.0).timeout.connect(func():
		if is_instance_valid(self):
			queue_free()
	)

@rpc("any_peer", "reliable")
func notify_client_death():
	if multiplayer.get_remote_sender_id() != 1:
		return
	GameEvents.local_player_died.emit()
	acknowledge_death.rpc_id(1)

@rpc("any_peer", "call_local", "reliable")
func acknowledge_death():
	if not multiplayer.is_server(): 
		return
	queue_free()
