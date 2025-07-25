extends Node

const _a_PROGRESS_SCENE_PATH = "res://Scenes/Title_Screen/Progress/Progress_%s.tscn"

func _ready():
	var global_si = Global.get_singleton(self, "Global")
	global_si.reset()
	
	var progress_id = "None"
	var save_file_idx = Global_Data.get_save_file_idx()
	if save_file_idx != -1:
		var path = Global.get_save_path() % str(save_file_idx)
		var data = Data_Parser.load_var_data(path)
		progress_id = data["Singletons"]["Progress"]["Progress"]["ID"]
	
	var scene = load(_a_PROGRESS_SCENE_PATH % progress_id)
	var instance = scene.instantiate()
	add_child(instance)
