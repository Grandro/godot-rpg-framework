extends "res://Global_Scenes/Debug/Scenes/Entry_List/Scripts/Entry_List.gd"

func instantiate_entry_(p_point, p_name = ""):
	if !_e_enumerate:
		p_name = str(p_point)
	
	var instance = instantiate_entry(p_name)
	instance.set_point(p_point)
	
	return instance

func instantiate_entry_from_data(p_data):
	var point = p_data["Point"]
	var name_ = p_data["Name"]
	var instance = instantiate_entry_(point, name_)
	
	return instance

func get_points():
	var points = []
	for instance in get_entries():
		var point = instance.get_point()
		points.push_back(point)
	
	return points
