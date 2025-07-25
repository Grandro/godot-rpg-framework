extends "res://Global_Scenes/Debug/Command_Editor/Entries/Scripts/Entry_Object.gd"

func _update_display_main_base_args():
	var object_text = _get_display_text(_a_data["Object"])
	var point_selected = _a_data["Point"]["Selected"]
	
	var text = object_text
	if point_selected:
		var point_text = _get_display_text(_a_data["Point"])
		text += " %s" % str(point_text)
	_a_Main.set_base_args(text)
