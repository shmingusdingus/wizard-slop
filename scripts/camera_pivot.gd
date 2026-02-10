extends Marker3D


func _ready():
	set_as_top_level(true)
	
	 # Wait a frame to ensure the parent's name/authority is set by the spawner
	await get_tree().process_frame 
	
	# Only the player who owns this node should make this camera active
	if get_parent().is_multiplayer_authority():
		$Camera3D.make_current()

func _process(_delta):
	if !get_parent().is_multiplayer_authority(): return

	global_position = get_parent().global_position
