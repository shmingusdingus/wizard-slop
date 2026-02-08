extends Node

@onready var projectile_spawner: MultiplayerSpawner = $ProjectileSpawner

func _ready():
	$UserInterface/Retry.hide()
	projectile_spawner.spawn_function = _on_projectile_spawn_requested

func _on_projectile_spawn_requested(data: Dictionary) -> Node:
	var res_f = load(data.f)
	var proj = res_f.projectile_scene.instantiate()

	proj.set_direction(data.dir)

	# Use transform (local) here. 
	# If the ProjectileSpawner node is at (0,0,0), 
	# then local transform == global transform.
	proj.transform = data.trans

	var spell = Spell.new(load(data.e), res_f, load(data.m))
	proj.initialize(spell)

	return proj

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and $UserInterface/Retry.visible:
		get_tree().reload_current_scene()

func _on_server_button_pressed() -> void:
	if $UserInterface/ConnectionMenu/ConnectionContainer/ServerPort:
		var port_text = $UserInterface/ConnectionMenu/ConnectionContainer/ServerPort.text
		var port = 24454

		if not port_text.is_empty():
			port = int(port_text)

		if port >= 1 and port <= 65535:
			NetworkHandler.start_server(port)
			$UserInterface/ConnectionMenu.hide()

func _on_client_button_pressed() -> void:
	if $UserInterface/ConnectionMenu/ConnectionContainer/ServerIp and $UserInterface/ConnectionMenu/ConnectionContainer/ServerPort:
		var ip = $UserInterface/ConnectionMenu/ConnectionContainer/ServerIp.text
		var port_text = $UserInterface/ConnectionMenu/ConnectionContainer/ServerPort.text
		var port = 24454
		
		if ip.is_empty():
			ip = "127.0.0.1"

		if not port_text.is_empty():
			port = int(port_text)

		if ip.is_valid_ip_address() and port >= 1 and port <= 65535:
			NetworkHandler.start_client(ip, port)
			$UserInterface/ConnectionMenu.hide()
