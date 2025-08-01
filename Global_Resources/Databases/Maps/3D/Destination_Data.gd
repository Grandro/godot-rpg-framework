extends "res://Global_Resources/Databases/Maps/Destination_Data_Base.gd"

@export var _e_pos: Vector3 = Vector3.ZERO
@export var _e_camera_limit: Dictionary[Side, float] = {SIDE_LEFT: -10000000.0,
														SIDE_TOP: -10000000.0,
														SIDE_RIGHT: 10000000.0,
														SIDE_BOTTOM: 10000000.0}

func get_pos():
	return _e_pos

func get_camera_limit():
	return _e_camera_limit
