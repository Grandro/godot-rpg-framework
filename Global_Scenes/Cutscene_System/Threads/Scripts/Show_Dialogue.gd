extends "res://Global_Scenes/Cutscene_System/Threads/Scripts/Thread_Base.gd"

var _a_key_type = ""
var _a_key = ""
var _a_process_type = ""
var _a_start_idx = -1
var _a_end_idx = -1
var _a_layer = -1
var _a_fade_out = false

func _ready():
	super()
	if !_a_loads_data:
		var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
		_a_key_type = cutscene_system_si.get_option_value(_a_args["Key_Type"])
		_a_key = cutscene_system_si.get_option_value(_a_args["Key"])
		_a_process_type = cutscene_system_si.get_option_value(_a_args["Process_Type"])
		_a_start_idx = cutscene_system_si.get_option_value(_a_args["Start_Idx"])
		_a_end_idx = cutscene_system_si.get_option_value(_a_args["End_Idx"])
		_a_layer = cutscene_system_si.get_option_value(_a_args["Layer"])
		_a_fade_out = cutscene_system_si.get_option_value(_a_args["Fade_Out"])
		_process_command()

func skip():
	super()
	if !_a_key.is_empty():
		var dialogue_system_si = Global.get_singleton(self, "Dialogue_System")
		dialogue_system_si.skip(_a_key)

func _process_command():
	if !_a_key.is_empty():
		var dialogue_system_si = Global.get_singleton(self, "Dialogue_System")
		dialogue_system_si.dialogue(_a_key, null, _a_process_type, _a_fade_out,
									_a_start_idx, _a_end_idx, _a_key_type)
		dialogue_system_si.set_dialogue_process_mode(_a_key, process_mode)
		dialogue_system_si.set_dialogue_layer(_a_key, _a_layer)
		dialogue_system_si.set_dialogue_completed_cb(_a_key, _CB_dialogue_completed)
	else:
		_emit_completed()
		queue_free()
	
	if _a_process_type != "Main" && !_a_loads_data:
		_emit_completed()
	
	super()

func get_save_data():
	var data = super()
	var args = data["Args"]
	args["Process_Type"] = _a_process_type
	
	return data

func load_data(p_data):
	super(p_data)
	
	var args = p_data["Args"]
	_a_process_type = args["Process_Type"]
	
	# Don't process command!
	# This is handled in Dialogue_System

func _CB_dialogue_completed(_p_key):
	if _a_process_type != "Sub":
		_emit_completed()
	queue_free()
