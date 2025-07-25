extends Button

@export var _e_command: String = ""
@export var _e_scene_paths : Dictionary = {"2D": "", "3D": ""}

func get_command():
	return _e_command

func get_scene_paths():
	return _e_scene_paths
