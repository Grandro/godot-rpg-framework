extends Window

@export var _e_sub_world: bool = true # Has own singletons?
@export var _e_game_world: bool = true # Should nodes execute all logic?
@export var _e_resize: bool = true # Resize if root VP resizes?
@export var _e_activate_physics = true # Activate PhysicsServer3D?

func _ready():
	var world3D = find_world_3d()
	var space = world3D.get_space()
	PhysicsServer3D.space_set_active(space, _e_activate_physics)

func is_sub_world():
	return _e_sub_world

func is_game_world():
	return _e_game_world

func get_resize():
	return _e_resize
