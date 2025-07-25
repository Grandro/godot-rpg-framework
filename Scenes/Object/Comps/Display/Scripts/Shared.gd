extends "res://Scripts/Extension_Base.gd"

func get_save_data():
	var data = {}
	data["Frame"] = _a_entity.get_frame()
	data["Modulate"] = _a_entity.get_modulate()
	
	return data

func load_data(p_data):
	_a_entity.set_frame(p_data["Frame"])
	_a_entity.set_modulate(p_data["Modulate"])
