extends "res://Global_Scenes/Debug/Command_Editor/Entries/Scripts/Entry_Command.gd"

# Breakable: 
func _update_display_main_base_args():
	var type = _a_data["Type"]["Value"]
	var amount_text = _get_display_text(_a_data["Amount"])
	
	var text = "Coins"
	match type:
		"Gain": text += " +"
		"Lose": text += " -"
	text += str(amount_text)
	_a_Main.set_base_args(text)
