extends "res://Global_Scenes/Debug/Scenes/Value_Select/Scripts/Value_Options.gd"

func update_options():
	_clear_options()
	
	var maps_data = Databases.get_data("Maps")
	var locations = maps_data.keys()
	for i in maps_data.size():
		var location = locations[i]
		_a_option_idxs[location] = i
		_a_Value.add_item(location)
		_a_Value.set_item_metadata(i, location)
