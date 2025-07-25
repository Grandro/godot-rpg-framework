extends NavigationAgent3D

signal path_finished() # Reached end of path

@export var _e_path: Array[Vector3] = []
@export_enum("One_Way", "Cycle", "Back_Forth") var _e_move_type = "One_Way"

var _a_entity = null
var _a_entity_comph : CompHandler = null
var _a_movement = null

var _a_path_idx = -1
var _a_back_forth = "Forth"
var _a_velocity = Vector3.ZERO

func _ready():
	set_physics_process(false)

func _physics_process(_p_delta):
	var to = get_next_path_position()
	if is_navigation_finished():
		return
	var from = _a_entity.get_global_position()
	var to_vec = from.direction_to(to)
	var speed = _a_movement.get_speed()
	var velocity_ = to_vec * speed
	
	if get_avoidance_enabled():
		set_velocity(velocity_)
	else:
		_set_velocity(velocity_)

func init(p_entity):
	_a_entity = p_entity
	_a_entity_comph = p_entity.comph()
	_a_movement = _a_entity_comph.get_comp("Movement")
	
	navigation_finished.connect(_on_navigation_finished)
	velocity_computed.connect(_on_velocity_computed)
	
	if !_e_path.is_empty():
		set_path(_e_path)

func reset_velocity():
	var init_velocity = _a_movement.get_init_velocity()
	_set_velocity(init_velocity)
	set_velocity_forced(init_velocity)

func adjust_velocity_post(p_velocity):
	return p_velocity

func _update_path_idx():
	match _e_move_type:
		"One_Way": 
			_a_path_idx += 1
		"Cycle": 
			_a_path_idx = (_a_path_idx + 1) % _e_path.size()
		"Back_Forth":
			match _a_back_forth:
				"Forth":
					_a_path_idx += 1
					if _a_path_idx == _e_path.size() - 1:
						_a_back_forth = "Back"
				"Back":
					_a_path_idx -= 1
					if _a_path_idx == 0:
						_a_back_forth = "Forth"

func set_path(p_path):
	_e_path.assign(p_path)
	_a_path_idx = 0
	_a_back_forth = "Forth"
	
	var is_empty = p_path.is_empty()
	set_physics_process(!is_empty)
	if is_empty:
		reset_velocity()
	else:
		set_target_position(p_path[_a_path_idx])

func get_velocity_():
	return _a_velocity

func get_speed():
	return 0.0

func _set_velocity(p_velocity):
	_a_velocity = p_velocity
	
	if p_velocity.length() > 0.0:
		var global_pos = _a_entity.get_global_position()
		var pos = global_pos + p_velocity
		var dir = Global.get_dir_to_pos(global_pos, pos)
		_a_movement.set_dir(dir)
		_a_entity_comph.call_comp("Anims", "update_anim")

func get_save_data():
	return {}

func load_data(_p_data):
	pass

func load_data_init():
	pass

func _on_navigation_finished():
	_update_path_idx()
	
	if _a_path_idx == _e_path.size():
		# Only happens if e_move_type == "One_Way"
		set_physics_process(false)
		reset_velocity()
		path_finished.emit()
	else:
		set_target_position(_e_path[_a_path_idx])

func _on_velocity_computed(p_velocity):
	_set_velocity(p_velocity)
