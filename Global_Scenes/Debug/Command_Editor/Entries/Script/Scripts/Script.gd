extends "res://Global_Scenes/Debug/Command_Editor/Entries/Scripts/Entry_Command.gd"

# Breakable: ["Instance_Key"]
func _update_warnings_add():
	_update_warnings_add_expression(_a_data, ["Instance_Key"])

func _update_display_main_base_args():
	var instance_key = _a_data["Instance_Key"]
	var expression = _a_data["Expression"]
	var type = _a_data["Type"]
	var text = instance_key
	if type == "Object":
		var comp = _a_data["Comp"]
		text += ": %s" % comp
	text += ": %s" % expression
	_a_Main.set_base_args(text)
