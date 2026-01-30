extends MultiplayerSpawner

@export var network_player: PackedScene
@export var team_zed_pos_spawn: Marker3D
@export var team_zed_neg_spawn: Marker3D

var player_teams = {}

func _ready() -> void:
	spawn_function = _custom_spawn_function
	
	multiplayer.peer_connected.connect(spawn_player)
	multiplayer.peer_disconnected.connect(remove_player)

func _custom_spawn_function(data: Dictionary) -> Node:
	var player = network_player.instantiate()
	player.name = str(data.id)
	player.position = data.pos
	player.rotation_degrees.y = data.rot.y
	
	return player

func spawn_player(id: int) -> void:
	if !multiplayer.is_server(): return
		
	var spawn_position = calculate_team_spawn_position(id)
	
	var spawn_data = {"id": id, "pos": spawn_position.global_position, "rot": spawn_position.global_rotation_degrees}
	spawn(spawn_data) 

func calculate_team_spawn_position(id: int):
	# Calculate which team has fewer players
	var team_zed_pos_count = 0
	var team_zed_neg_count = 0
	for team in player_teams.values():
		if team == 0: team_zed_pos_count += 1
		else: team_zed_neg_count += 1

	var assigned_team = 0 if team_zed_pos_count <= team_zed_neg_count else 1
	player_teams[id] = assigned_team
	
	var spawn_position = team_zed_pos_spawn if assigned_team == 0 else team_zed_neg_spawn
	
	return spawn_position

func remove_player(id: int) -> void:
	if !multiplayer.is_server(): return
	
	player_teams.erase(id)
	
	var player_node = get_node(spawn_path).get_node_or_null(str(id))
	if player_node:
		player_node.queue_free()
