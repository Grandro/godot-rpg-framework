extends "res://Global_Scenes/Debug/Scenes/Value_Select/Scripts/Value_Options.gd"

func update_options():
	_clear_options()
	
	var equipment_groups = Global.get_equipment_groups()
	for i in equipment_groups.size():
		var group = equipment_groups[i]
		var loc_id = _e_options_loc_id % group.to_upper()
		_a_option_idxs[group] = i
		_a_Value.add_item(tr(loc_id))
		_a_Value.set_item_metadata(i, group)
