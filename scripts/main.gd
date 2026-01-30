extends Node

@onready var projectile_spawner: MultiplayerSpawner = $ProjectileSpawner

func _ready():
	$UserInterface/Retry.hide()
	projectile_spawner.spawn_function = _on_projectile_spawn_requested

func _on_projectile_spawn_requested(data: Dictionary) -> Node:
	var res_e = load(data.e)
	var res_f = load(data.f)
	var res_m = load(data.m)

	var proj = res_f.projectile_scene.instantiate()

	proj.set_direction(data.dir)
	proj.position = data.pos
	proj.transform = data.trans

	var spell = Spell.new(res_e, res_f, res_m)
	proj.initialize(spell)

	return proj

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and $UserInterface/Retry.visible:
		get_tree().reload_current_scene()
	if event.is_action_pressed("create_server"):
		NetworkHandler.start_server()
	if event.is_action_pressed("create_client"):
		NetworkHandler.start_client()
