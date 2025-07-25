extends Camera2D

signal made_current()

func init(_p_entity):
	pass

func make_current_():
	make_current()
	made_current.emit()

func get_save_data():
	return {}

func load_data(_p_data):
	pass

func load_data_init():
	pass
