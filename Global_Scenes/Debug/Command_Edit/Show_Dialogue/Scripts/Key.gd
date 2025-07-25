extends "res://Global_Scenes/Debug/Scenes/Value_Select/Scripts/Value_Options.gd"

var _a_key_type = ""

func update_options():
	_clear_options()
	
	var dialogues_data = Databases.get_global_map_data("Dialogues", _a_key_type)
	var keys = dialogues_data.keys()
	for i in keys.size():
		var key = keys[i]
		_a_option_idxs[key] = i
		_a_Value.add_item(key)
		_a_Value.set_item_metadata(i, key)

func set_key_type(p_key_type):
	_a_key_type = p_key_type
