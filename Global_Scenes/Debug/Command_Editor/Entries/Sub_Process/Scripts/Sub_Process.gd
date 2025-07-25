extends "res://Global_Scenes/Debug/Command_Editor/Entries/Scripts/Entry_Branch.gd"

# Breakable:
func _update_display_main_base_args():
	var id_text = _get_display_text(_a_data["ID"])
	_a_Main.set_base_args(id_text)

func _update_branches():
	var margin = _get_main_arg_margin()
	_a_Main.set_collapse_visible(true)
	_a_End.set_left_margin(margin)

func get_cutscene_data():
	return get_save_data()
