extends SubViewport

@export var _e_sub_world: bool = true # Has own singletons?
@export var _e_game_world: bool = true # Should nodes execute all logic?
@export var _e_resize: bool = true # Resize if root VP resizes?
@export var _e_activate_physics = true # Activate PhysicsServer3D?

#var _a_base_size = Vector2.ZERO

func _ready():
	#_a_base_size = get_size()
	#set_size_2d_override(_a_base_size)
	
	var world3D = find_world_3d()
	var space = world3D.get_space()
	PhysicsServer3D.space_set_active(space, _e_activate_physics)

func resize():
	pass
	#var root = get_tree().get_root()
	#var root_size = root.get_size()
	#set_size(root_size)
	#set_size_2d_override(_a_base_size)

func is_sub_world():
	return _e_sub_world

func is_game_world():
	return _e_game_world

func get_resize():
	return _e_resize

#func set_base_size(p_base_size):
#	_a_base_size = p_base_size
