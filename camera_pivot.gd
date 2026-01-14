extends Marker3D

@export var target: Node3D

func _process(_delta):
	if not target:
		return

	global_position.x = target.global_position.x
