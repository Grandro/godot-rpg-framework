extends "res://Global_Scenes/Debug/Scenes/Value_Select/Scripts/Value_Options.gd"

var _a_interaction_count = -1

func update_options():
	_clear_options()
	
	for i in _a_interaction_count:
		_a_option_idxs[i] = i
		_a_Value.add_item(str(i))
		_a_Value.set_item_metadata(i, i)

func set_interaction_count(p_interaction_count):
	_a_interaction_count = p_interaction_count
