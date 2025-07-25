extends "res://Global_Scenes/Debug/Command_Editor/Entries/Scripts/Entry_Command.gd"

# Breakable:
func _update_display_main_args():
	var time_text = _get_display_text(_a_data["Time"])
	var text = time_text
	text += " %s" % tr("SECONDS")
	_a_Main.set_base_args(text)
