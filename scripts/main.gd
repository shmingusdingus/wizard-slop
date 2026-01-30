extends Node

@onready var projectile_spawner: MultiplayerSpawner = $ProjectileSpawner

func _ready():
	$UserInterface/Retry.hide()
	projectile_spawner.spawn_function = _on_projectile_spawn_requested

func _on_projectile_spawn_requested(data: Dictionary) -> Node:
	# 1. Load resources from the paths we sent in the RPC
	var res_e = load(data.e)
	var res_f = load(data.f)
	var res_m = load(data.m)
	
	# 2. Build the projectile
	var proj = res_f.projectile_scene.instantiate()
	
	# 3. Position it correctly immediately
	proj.direction = data.dir
	proj.global_position = data.pos
	proj.global_transform = data.trans
	
	# 4. Initialize the spell so colors/stats are set on this client
	var spell = Spell.new(res_e, res_f, res_m)
	proj.initialize(spell)
	
	# IMPORTANT: Returning the node tells the Spawner to add it to the 
	# tree at the "Spawn Path" you set in the Inspector.
	return proj

#func _on_mob_timer_timeout() -> void:
	## Create a new instance of the Mob scene.
	#var mob = mob_scene.instantiate()
#
	## Choose a random location on the SpawnPath.
	## We store the reference to the SpawnLocation node.
	#var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
	## And give it a random offset.
	#mob_spawn_location.progress_ratio = randf()
#
	#var player_position = $Player.position
	#mob.initialize(mob_spawn_location.position, player_position)
#
	## Spawn the mob by adding it to the Main scene.
	#add_child(mob)
#
	## We connect the mob to the score label to update the score upon squashing one.
	#mob.squashed.connect($UserInterface/ScoreLabel._on_mob_squashed.bind())

#func _on_player_hit() -> void:
	#$MobTimer.stop()
	#$UserInterface/Retry.show()

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and $UserInterface/Retry.visible:
		get_tree().reload_current_scene()
	if event.is_action_pressed("create_server"):
		NetworkHandler.start_server()
	if event.is_action_pressed("create_client"):
		NetworkHandler.start_client()
