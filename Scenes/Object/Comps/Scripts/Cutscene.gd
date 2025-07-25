extends Node

var _a_in_cutscene = 0 # 0: not in cutscene, >0: in cutscene
var _a_disabled_by_cutscene = 0 # 0: not disabled, >0: disabled

func init(_p_entity):
	pass

func increase_in_cutscene():
	set_in_cutscene(_a_in_cutscene + 1)

func decrease_in_cutscene():
	set_in_cutscene(_a_in_cutscene - 1)

func increase_disabled_by_cutscene():
	set_disabled_by_cutscene(_a_disabled_by_cutscene + 1)

func decrease_disabled_by_cutscene():
	set_disabled_by_cutscene(_a_disabled_by_cutscene - 1)

func set_in_cutscene(p_in_cutscene):
	_a_in_cutscene = p_in_cutscene

func set_disabled_by_cutscene(p_disabled):
	_a_disabled_by_cutscene = p_disabled

func is_in_cutscene():
	return _a_in_cutscene > 0

func is_disabled_by_cutscene():
	return _a_disabled_by_cutscene > 0

func get_save_data():
	var data = {}
	data["Disabled_By_Cutscene"] = _a_disabled_by_cutscene
	
	return data

func load_data(p_data):
	set_disabled_by_cutscene(p_data["Disabled_By_Cutscene"])

func load_data_init():
	pass
