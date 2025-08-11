extends Node

signal to_disabled()
signal to_enabled()

var _a_disabled = 0 # 0 = enabled, >0 = disabled

func init(_p_entity):
	pass

func disable():
	if _a_disabled == 0:
		to_disabled.emit()
	_a_disabled += 1

func enable():
	if _a_disabled == 1:
		to_enabled.emit()
	_a_disabled -= 1

func get_save_data():
	var data = {}
	data["Disabled"] = _a_disabled
	
	return data

func load_data(p_data):
	_a_disabled = p_data["Disabled"]
	if _a_disabled == 0:
		to_enabled.emit()
	else:
		to_disabled.emit()

func load_data_init():
	pass
