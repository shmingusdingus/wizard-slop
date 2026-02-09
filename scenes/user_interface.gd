extends Control

func _ready():
	$RespawnScreen.hide()
	GameEvents.local_player_died.connect(_on_player_death_signal)

# Respawn Screen

func _on_player_death_signal():
	$RespawnScreen.show()

func _on_respawn_button_pressed() -> void:
	$RespawnScreen.hide()
	var spawner = get_tree().get_first_node_in_group("player_spawner")
	spawner.request_respawn.rpc_id(1)

# Connection Screen

func _on_server_button_pressed() -> void:
	if $ConnectionScreen/ConnectionContainer/ServerPort:
		var port_text = $ConnectionScreen/ConnectionContainer/ServerPort.text
		var port = 24454

		if not port_text.is_empty():
			port = int(port_text)

		if port >= 1 and port <= 65535:
			NetworkHandler.start_server(port)
			$ConnectionScreen.hide()

func _on_client_button_pressed() -> void:
	if $ConnectionScreen/ConnectionContainer/ServerIp and $ConnectionScreen/ConnectionContainer/ServerPort:
		var ip = $ConnectionScreen/ConnectionContainer/ServerIp.text
		var port_text = $ConnectionScreen/ConnectionContainer/ServerPort.text
		var port = 24454
		
		if ip.is_empty():
			ip = "127.0.0.1"

		if not port_text.is_empty():
			port = int(port_text)

		if ip.is_valid_ip_address() and port >= 1 and port <= 65535:
			NetworkHandler.start_client(ip, port)
			$ConnectionScreen.hide()
