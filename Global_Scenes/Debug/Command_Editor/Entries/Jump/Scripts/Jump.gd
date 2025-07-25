extends "res://Global_Scenes/Debug/Command_Editor/Entries/Scripts/Entry_Object.gd"

func _update_display_main_base_args():
	var object_text = _get_display_text(_a_data["Object"])
	var point_selected = _a_data["Point"]["Selected"]
	var point_text = _get_display_text(_a_data["Point"])
	var wait_finish = _a_data["Wait_Finish"]["Value"]
	
	var text = object_text
	if point_selected:
		text += " %s" % str(point_text)
	if wait_finish:
		text += " (%s)" % tr("WAIT")
	_a_Main.set_base_args(text)
