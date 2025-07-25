extends "res://Global_Scenes/Debug/Command_Editor/Entries/Scripts/Entry_Command.gd"

# Breakable:
func _update_display_main_args():
	var id_text = _get_display_text(_a_data["ID"])
	_a_Main.set_base_args(id_text)
