extends "res://Global_Scenes/Debug/Scenes/Value_Select/Scripts/Value_Options.gd"

func update_options():
	var prev = get_selected_key()
	super()
	
	if has_key(prev):
		select(prev)
