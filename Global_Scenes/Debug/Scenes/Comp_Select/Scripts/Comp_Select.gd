extends "res://Global_Scenes/Debug/Scenes/Value_Select/Scripts/Value_Options.gd"

var _a_object = null

func update_options():
	_clear_options()
	
	var comps = _a_object.comph().get_comps()
	var comp_keys = comps.keys()
	for i in comp_keys.size():
		var comp = comp_keys[i]
		_a_option_idxs[comp] = i
		_a_Value.add_item(comp)
		_a_Value.set_item_metadata(i, comp)

func set_object(p_object):
	_a_object = p_object
