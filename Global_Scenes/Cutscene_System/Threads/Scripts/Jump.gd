extends "res://Global_Scenes/Cutscene_System/Threads/Scripts/Thread_Base.gd"

@export var _e_dimensions : GDScript = null

var _a_dimensions = null

var _a_object_key = ""
var _a_keep_dir = false
var _a_point_selected = false
var _a_wait_finish = false
var _a_pos = null # Vector
var _a_tween = null
var _a_tween_elapsed_time = 0.0

func _ready():
	super()
	_a_dimensions = _e_dimensions.new(self)
	
	if !_a_loads_data:
		var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
		_a_object_key = cutscene_system_si.get_option_value(_a_args["Object"])
		_a_keep_dir = cutscene_system_si.get_option_value(_a_args["Keep_Dir"])
		_a_point_selected = _a_args["Point"]["Selected"]
		_a_wait_finish = cutscene_system_si.get_option_value(_a_args["Wait_Finish"])
		
		if _a_point_selected:
			var point = cutscene_system_si.get_option_value(_a_args["Point"])
			var grid_step = _a_args["Grid"]["Step"]
			var grid_start = _a_args["Grid"]["Start"]
			_a_pos = Global.grid_point_to_pos(point, grid_step, grid_start)
		
		_process_command()

func skip():
	super()
	if _a_tween != null:
		_a_tween.kill()
	
	_a_object.set_global_position(_a_pos)
	_a_object.comph().call_comp("States", "set_state_tmp", ["Stop"])
	_a_object.comph().call_comp("Anims", "update_anim")
	_a_object.comph().call_comp("Movement", "stop")
	
	_emit_completed()
	queue_free()

func _process_command():
	var global_si = Global.get_singleton(self, "Global")
	_a_object = global_si.get_object(_a_object_key)
	_a_object.comph().call_comp("Cutscene", "increase_in_cutscene")
	
	if !_a_point_selected:
		_a_pos = _a_object.get_global_position()
	
	_jump_object_to_pos()
	
	var movement_jump_comp = _a_object.comph().get_subcomp("Movement", "Jump")
	movement_jump_comp.jumped.connect(_on_Object_jumped)
	if !_a_wait_finish && !_a_skip && !_a_loads_data:
		_emit_completed()
	
	super()

func _jump_object_to_pos():
	if !_a_loads_data:
		var dir = ""
		if _a_keep_dir:
			dir = _a_object.comph().call_comp("Movement", "get_dir")
		else:
			var start_pos = _a_object.get_global_position()
			dir = Global.get_dir_to_pos(start_pos, _a_pos)
		_a_object.comph().call_comp("Movement", "set_dir", [dir])
		_a_object.comph().call_subcomp("Movement", "Jump", "jump")
	
	_tween_object_to_pos(0.5)

func _tween_object_to_pos(p_duration):
	_a_tween = create_tween()
	_a_dimensions.tween_object_to_pos(_a_tween, _a_object, _a_pos, p_duration)

func get_save_data():
	_add_revert_property(_a_object, _a_object_key, "$Main", "position")
	
	var data = super()
	var args = data["Args"]
	args["Object"] = {}
	args["Object"]["Value"] = _a_object_key
	args["Keep_Dir"] = _a_keep_dir
	args["Point_Selected"] = _a_point_selected
	args["Wait_Finish"] = _a_wait_finish
	args["Pos"] = _a_pos
	args["Tween_Elapsed_Time"] = _a_tween.get_total_elapsed_time()
	
	return data

func load_data(p_data):
	super(p_data)
	
	var args = p_data["Args"]
	_a_object_key = args["Object"]["Value"]
	_a_keep_dir = args["Keep_Dir"]
	_a_point_selected = args["Point_Selected"]
	_a_wait_finish = args["Wait_Finish"]
	_a_pos = args["Pos"]
	_a_tween_elapsed_time = args["Tween_Elapsed_Time"]
	
	_process_command()

func _on_Object_jumped():
	_a_object.comph().call_comp("States", "set_state_tmp", ["Stop"])
	_a_object.comph().call_comp("Anims", "update_anim")
	
	if !_a_skip:
		if _a_wait_finish:
			_emit_completed()
		queue_free()
