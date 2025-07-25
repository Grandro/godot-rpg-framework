extends "res://Scenes/Object/Comps/Movement/Comps/Scripts/Jump_Base.gd"

func _init():
	_a_gravity_vec = ProjectSettings.get_setting("physics/2d/default_gravity_vector")
	_a_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	_a_velocity = Vector2.ZERO

func _ready():
	set_physics_process(false)
