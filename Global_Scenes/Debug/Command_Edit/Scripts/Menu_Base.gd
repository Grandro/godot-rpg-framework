extends MarginContainer

@export var _e_key: String = ""

func get_key():
	return _e_key

func load_data(p_data):
	if p_data.is_empty():
		_load_data_init()
	else:
		_load_data(p_data)

func _load_data_init():
	pass

func _load_data(_p_data):
	pass
