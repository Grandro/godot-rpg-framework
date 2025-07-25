extends Resource

@export_enum("Down", "Left", "Right", "Up") var _e_dir = "Down"
@export var _e_camera_limit_active : bool = false

func get_dir():
	return _e_dir

func is_camera_limit_active():
	return _e_camera_limit_active
