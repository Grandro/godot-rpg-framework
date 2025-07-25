extends Node

signal data_loaded()

@export var _e_data: Dictionary = {}

func _ready():
	_init_data()

func _init_data():
	var debug_path = _e_data["Debug"]["Path"]
	var debug_data = Data_Parser.load_var_data(debug_path)
	if debug_data.is_empty():
		for key in ["Cutscenes", "Dialogues", "Stater"]:
			debug_data[key] = {}
			debug_data[key]["Global"] = {}
			debug_data[key]["Map"] = {}
	_e_data["Debug"]["Data"] = debug_data
	
	data_loaded.emit()

func write_data(p_key):
	var path = _e_data[p_key]["Path"]
	var data = _e_data[p_key]["Data"]
	Data_Parser.write_var_data(path, data)

func get_data(p_key):
	return _e_data[p_key]["Data"]

func get_data_entry(p_key, p_entry_key):
	return _e_data[p_key]["Data"][p_entry_key]

func get_debug_data(p_key):
	return _e_data["Debug"]["Data"][p_key]

func get_teleport_data(p_args):
	var data = get_data("Maps")
	for i in 3:
		match i:
			0: data = data[p_args[0]]
			1: data = data.get_destinations()
			2: data = data[p_args[1]]
	
	return data

func get_global_map_data(p_key, p_key_type, p_chapter = "", p_location = "", p_instance = self):
	var data = get_debug_data(p_key)[p_key_type]
	if p_key_type == "Map":
		if p_chapter.is_empty():
			var progress_si = Global.get_singleton(p_instance, "Progress")
			p_chapter = progress_si.get_chapter()
		if p_location.is_empty():
			var scene_manager_si = Global.get_singleton(p_instance, "Scene_Manager")
			p_location = scene_manager_si.get_location()
		data = data[p_chapter][p_location]
	
	return data
