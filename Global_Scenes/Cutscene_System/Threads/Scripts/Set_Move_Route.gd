extends "res://Global_Scenes/Cutscene_System/Threads/Scripts/Thread_Base.gd"

@export_enum("2D", "3D") var _e_dim = "2D"

var _a_object_key = ""
var _a_state_key = ""
var _a_speed_key = ""
var _a_path_pos = []
var _a_wait_finish = false

func _ready():
	super()
	if !_a_loads_data:
		var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
		_a_object_key = cutscene_system_si.get_option_value(_a_args["Object"])
		_a_state_key = cutscene_system_si.get_option_value(_a_args["State"])
		_a_speed_key = cutscene_system_si.get_option_value(_a_args["Speed"])
		_a_wait_finish = cutscene_system_si.get_option_value(_a_args["Wait_Finish"])
		var grid_step = _a_args["Grid"]["Step"]
		var grid_start = _a_args["Grid"]["Start"]
		var gen_points = _a_args["Gen_Path"]["Gen_Points"]
		for gen_point in gen_points:
			var pos = Global.grid_point_to_pos(gen_point, grid_step, grid_start)
			_a_path_pos.push_back(pos)
		
		_process_command()

func skip():
	super()
	var nav_agent_comp = _a_object.comph().get_subcomp("Movement", "Nav_Agent")
	nav_agent_comp.path_finished.disconnect(_on_Nav_Agent_path_finished)
	
	if !_a_path_pos.is_empty():
		var prev_pos = null
		if _a_path_pos.size() == 1:
			prev_pos = _a_object.get_global_position()
		else:
			prev_pos = _a_path_pos[-2]
		var new_pos = _a_path_pos[-1]
		var dir = Global.get_dir_to_pos(prev_pos, new_pos)
		
		_a_object.set_global_position(new_pos)
		_a_object.comph().call_subcomp("Movement", "Nav_Agent", "set_path", [[]])
		_a_object.comph().call_comp("States", "set_state_tmp", ["Stop"])
		_a_object.comph().call_comp("Movement", "set_dir", [dir])
		_a_object.comph().call_comp("Anims", "update_anim")
	
	_emit_completed()
	queue_free()

func _process_command():
	var global_si = Global.get_singleton(self, "Global")
	_a_object = global_si.get_object(_a_object_key)
	_a_object.comph().call_comp("Cutscene", "increase_in_cutscene")
	
	var nav_agent_comp = _a_object.comph().get_subcomp("Movement", "Nav_Agent")
	nav_agent_comp.path_finished.connect(_on_Nav_Agent_path_finished)
	
	if !_a_path_pos.is_empty():
		_move_object_to_pos(_a_path_pos[0])
	if (_a_path_pos.is_empty() || !_a_wait_finish) && !_a_skip && !_a_loads_data:
		_emit_completed()
	if _a_path_pos.is_empty() && !_a_skip:
		queue_free()
	
	super()

func _move_object_to_pos(p_pos):
	var base_speed = Cutscene_System.get_movement_base_speed(_e_dim, _a_speed_key)
	_a_object.comph().call_comp("States", "set_state_tmp", [_a_state_key])
	_a_object.comph().call_comp("Movement", "set_base_speed", [base_speed])
	_a_object.comph().call_subcomp("Movement", "Nav_Agent", "set_path", [[p_pos]])
	_a_object.comph().call_comp("Anims", "update_anim")

func get_save_data():
	_add_revert_property(_a_object, _a_object_key, "$Main", "position")
	
	var data = super()
	var args = data["Args"]
	args["Object"] = {}
	args["Object"]["Value"] = _a_object_key
	args["State_Key"] = _a_state_key
	args["Speed_Key"] = _a_speed_key
	args["Path_Pos"] = _a_path_pos
	args["Wait_Finish"] = _a_wait_finish
	
	return data

func load_data(p_data):
	super(p_data)
	
	var args = p_data["Args"]
	_a_object_key = args["Object"]["Value"]
	_a_state_key = args["State_Key"]
	_a_speed_key = args["Speed_Key"]
	_a_path_pos = args["Path_Pos"]
	_a_wait_finish = args["Wait_Finish"]
	
	_process_command()

func _on_Nav_Agent_path_finished():
	_a_path_pos.pop_front()
	
	if _a_path_pos.is_empty():
		_a_object.comph().call_comp("States", "set_state_tmp", ["Stop"])
		_a_object.comph().call_comp("Anims", "update_anim")
		if !_a_skip:
			if _a_wait_finish:
				_emit_completed()
			queue_free()
	else:
		_move_object_to_pos(_a_path_pos[0])
