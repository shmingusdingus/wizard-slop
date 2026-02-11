extends Area3D
class_name SpellProjectile

var direction: Vector3 = Vector3.ZERO
var speed: float = 10.0
var velocity: Vector3 = Vector3.ZERO
var element_color: Color = Color(1,1,1)
var damage: float = 50.0
var status_effect: String = ""
var orientation: Vector3 = Vector3.ZERO

var lifetime: float = 0.0
var motion_rune: MotionRune

func _ready():
	body_entered.connect(_on_body_entered)

	if multiplayer.is_server():
		get_tree().create_timer(5.0).timeout.connect(queue_free)

func _on_body_entered(body):
	if not multiplayer.is_server():
		return

	if body.has_method("take_damage"):
		body.take_damage(damage)

	queue_free()

func initialize(spell: Spell):
	spell.apply_to_projectile(self)

func set_element_color(c: Color):
	var mesh = $MeshInstance3D
	if not mesh.material_override:
		mesh.material_override = StandardMaterial3D.new()
	mesh.material_override.albedo_color = c

func set_orientation(dir: Vector3):
	orientation = dir.normalized()

func set_direction(dir: Vector3):
	direction = dir.normalized()

func set_speed(s: float):
	speed = s

func set_velocity(dir: Vector3):
	velocity = dir.normalized() * velocity.length()

func _physics_process(delta):
	lifetime += delta
	var motion_step: Vector3

	if motion_rune:
		motion_step = motion_rune.update_position(self, delta)
	else:
		motion_step = direction * speed * delta

	if motion_step.length_squared() > 0.0001:
		var target_pos = global_position + motion_step
		look_at(target_pos, Vector3.UP)

	global_position += motion_step
