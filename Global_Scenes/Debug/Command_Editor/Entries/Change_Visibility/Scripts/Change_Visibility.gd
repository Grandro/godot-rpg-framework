extends "res://Global_Scenes/Debug/Command_Editor/Entries/Scripts/Entry_Object.gd"

func _update_display_main_base_args():
	var object_text = _get_display_text(_a_data["Object"])
	var is_visible_ = _a_data["Visible"]["Value"]
	
	var text = ""
	if is_visible_:
		text += tr("SHOW")
	else:
		text += tr("HIDE")
	text += " %s" % object_text
	_a_Main.set_base_args(text)
