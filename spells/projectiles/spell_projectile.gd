extends Area3D
class_name SpellProjectile

var velocity: Vector3 = Vector3.ZERO
var element_color: Color = Color(1,1,1)
var damage: float = 1.0
var status_effect: String = ""

func initialize(spell: Spell):
	spell.apply_to_projectile(self)

func set_element_color(c: Color):
	var mesh = $MeshInstance3D
	if not mesh.material_override:
		mesh.material_override = StandardMaterial3D.new()
	mesh.material_override.albedo_color = c

func set_speed(s: float):
	velocity = velocity.normalized() * s

func set_velocity(v: Vector3):
	velocity = v

func _physics_process(delta):
	global_position += velocity * delta
