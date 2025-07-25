extends "res://Scenes/Object/Comps/Movement/Comps/Scripts/Jump_Base.gd"

func _init():
	_a_gravity_vec = ProjectSettings.get_setting("physics/3d/default_gravity_vector")
	_a_gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	_a_velocity = Vector3.ZERO
