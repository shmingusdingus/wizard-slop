extends Node

@onready var projectile_spawner: MultiplayerSpawner = $ProjectileSpawner

func _ready():
	projectile_spawner.spawn_function = _on_projectile_spawn_requested

func _on_projectile_spawn_requested(data: Dictionary) -> Node:
	var res_f = load(data.f)
	var proj = res_f.projectile_scene.instantiate()

	proj.set_direction(data.dir)

	proj.transform = data.trans

	var spell = Spell.new(load(data.e), res_f, load(data.m))
	proj.initialize(spell)

	return proj
