extends Node
class_name NodeObject

var _a_comph = CompHandler.new(self)

func _ready():
	_a_comph.register_comps()

func comph():
	return _a_comph

func get_save_data():
	return {}

func load_data(_p_data):
	pass

func load_data_init():
	pass
