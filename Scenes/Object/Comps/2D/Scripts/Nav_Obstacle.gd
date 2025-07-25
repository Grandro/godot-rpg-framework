extends NavigationObstacle2D

var _a_Shared = preload("res://Scenes/Object/Comps/Nav_Obstacle/Scripts/Shared.gd")

var _a_shared = null

func _ready():
	_a_shared = _a_Shared.new(self)
	_a_shared.ready()

func init(_p_entity):
	pass

func get_save_data():
	return {}

func load_data(_p_data):
	pass

func load_data_init():
	pass
