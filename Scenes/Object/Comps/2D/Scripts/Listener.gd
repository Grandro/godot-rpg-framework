extends AudioListener2D

var _a_Shared = preload("res://Scenes/Object/Comps/Listener/Scripts/Shared.gd")

var _a_shared = null

func _ready():
	_a_shared = _a_Shared.new(self)

func init(p_entity):
	_a_shared.init(p_entity)

func get_save_data():
	return _a_shared.get_save_data()

func load_data(p_data):
	_a_shared.load_data(p_data)

func load_data_init():
	pass
