extends Node

var _a_key = ""

func init(p_entity):
	_a_key = p_entity.get_name()

func get_key():
	return _a_key

func get_save_data():
	return {}

func load_data(_p_data):
	pass

func load_data_init():
	pass
