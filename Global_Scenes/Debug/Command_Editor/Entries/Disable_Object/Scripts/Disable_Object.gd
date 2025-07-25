extends "res://Global_Scenes/Debug/Command_Editor/Entries/Scripts/Entry_Object.gd"

func _update_display_main_base_args():
	var is_disabled = _a_data["Disable"]["Value"]
	var object_text = _get_display_text(_a_data["Object"])
	
	var text = ""
	if is_disabled:
		text += tr("DEBUG_CUTSCENES_DISABLE")
	else:
		text += tr("DEBUG_CUTSCENES_ENABLE")
	text += " %s" % object_text
	_a_Main.set_base_args(text)
