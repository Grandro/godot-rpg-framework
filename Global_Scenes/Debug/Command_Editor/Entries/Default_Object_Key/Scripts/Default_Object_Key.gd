extends "res://Global_Scenes/Debug/Command_Editor/Entries/Scripts/Entry_Object.gd"

func add_res_data(p_res_data, p_args = []):
	super(p_res_data, p_args)
	
	var key = _a_data["Object"]["Value"]
	p_res_data["Default_Object"] = key

func _update_display_main_base_args():
	var object_text = _get_display_text(_a_data["Object"])
	_a_Main.set_base_args(object_text)
