extends "res://Global_Scenes/Cutscene_System/Threads/Scripts/Thread_Base.gd"

var _a_type = ""
var _a_anim = ""
var _a_mask_path = ""
var _a_wait_finish = false
var _a_anim_pos = 0.0

func _ready():
	super()
	if !_a_loads_data:
		var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
		_a_type = cutscene_system_si.get_option_value(_a_args["Type"])
		_a_anim = cutscene_system_si.get_option_value(_a_args["Anim"])
		_a_mask_path = cutscene_system_si.get_option_value(_a_args["Mask"])
		_a_wait_finish = cutscene_system_si.get_option_value(_a_args["Wait_Finish"])
		_process_command()

func skip():
	super()
	
	match _a_type:
		"Trans":
			var global_si = Global.get_singleton(self, "Global")
			match _a_anim:
				"Fade_In": global_si.show_trans(_a_mask_path, "Faded_In")
				"Fade_Out": global_si.show_trans(_a_mask_path, "Faded_Out")
				"Fade_Out_In": global_si.show_trans(_a_mask_path, "Faded_In")
	
	_emit_completed()
	queue_free()

func _process_command():
	match _a_type:
		"Trans":
			var global_si = Global.get_singleton(self, "Global")
			global_si.trans_finished.connect(_on_Global_trans_finished)
			global_si.show_trans(_a_mask_path, _a_anim)
			global_si.seek_trans_anim(_a_anim_pos)
	
	if !_a_wait_finish && !_a_skip && !_a_loads_data:
		_emit_completed()
	
	super()

func get_save_data():
	var global_si = Global.get_singleton(self, "Global")
	var data = super()
	var args = data["Args"]
	args["Type"] = _a_type
	args["Anim"] = _a_anim
	args["Mask_Path"] = _a_mask_path
	args["Wait_Finish"] = _a_wait_finish
	args["Anim_Pos"] = global_si.get_trans_anim_pos()
	
	return data

func load_data(p_data):
	super(p_data)
	
	var args = p_data["Args"]
	_a_type = args["Type"]
	_a_anim = args["Anim"]
	_a_mask_path = args["Mask_Path"]
	_a_wait_finish = args["Wait_Finish"]
	_a_anim_pos = args["Anim_Pos"]
	
	_process_command()

func _on_Global_trans_finished():
	if !_a_skip:
		_emit_completed()
		queue_free()
