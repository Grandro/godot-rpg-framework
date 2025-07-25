extends "res://Global_Scenes/Debug/Scenes/Value_Select/Scripts/Value_Options.gd"

func update_options():
	_clear_options()
	
	var popup_types = Global.get_popup_types()
	for i in popup_types.size():
		var type = popup_types[i]
		var loc_id = _e_options_loc_id % type.to_upper()
		_a_option_idxs[type] = i
		_a_Value.add_item(tr(loc_id))
		_a_Value.set_item_metadata(i, type)
