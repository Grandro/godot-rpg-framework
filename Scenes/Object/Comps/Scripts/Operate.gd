extends Node

signal to_disabled()
signal to_enabled()

var _a_enabled = 0 # 0 = enabled, >0 = disabled

func init(_p_entity):
	pass

func disable():
	if _a_enabled == 0:
		to_disabled.emit()
	_a_enabled += 1

func enable():
	if _a_enabled == 1:
		to_enabled.emit()
	_a_enabled -= 1

func get_save_data():
	var data = {}
	data["Enabled"] = _a_enabled
	
	return data

func load_data(p_data):
	_a_enabled = p_data["Enabled"]
	if _a_enabled == 0:
		to_enabled.emit()
	else:
		to_disabled.emit()

func load_data_init():
	pass
