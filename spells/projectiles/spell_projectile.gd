extends Area3D
class_name SpellProjectile

var direction: Vector3 = Vector3.ZERO
var speed: float = 10.0
var velocity: Vector3 = Vector3.ZERO
var element_color: Color = Color(1,1,1)
var damage: float = 1.0
var status_effect: String = ""
var orientation: Vector3 = Vector3.ZERO

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
	velocity = direction * speed
	global_position += velocity * delta
