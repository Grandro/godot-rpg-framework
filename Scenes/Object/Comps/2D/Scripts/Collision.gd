extends CollisionShape2D

var _a_Shared = preload("res://Scenes/Object/Comps/Collision/Scripts/Shared.gd")

var _a_shared = null

func _ready():
	_a_shared = _a_Shared.new(self)

func init(p_entity):
	_a_shared.init(p_entity)

func get_save_data():
	return {}

func load_data(_p_data):
	pass

func load_data_init():
	pass
