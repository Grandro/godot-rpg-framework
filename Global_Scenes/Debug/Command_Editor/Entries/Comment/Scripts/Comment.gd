extends "res://Global_Scenes/Debug/Command_Editor/Entries/Scripts/Entry_Command.gd"

# Breakable:
func _update_display_main_args():
	super()
	
	var text = _a_data["Text"]
	for wrapped_text in text:
		for text_line in wrapped_text:
			_instantiate_main_arg(text_line, _e_color)
