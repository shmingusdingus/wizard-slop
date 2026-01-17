extends Marker3D


func _ready():
	set_as_top_level(true)

func _process(_delta):
	if not get_parent().is_multiplayer_authority():
		return

	global_position.x = get_parent().global_position.x
