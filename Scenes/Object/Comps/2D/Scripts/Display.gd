extends Sprite2D

var _a_Shared = preload("res://Scenes/Object/Comps/Display/Scripts/Shared.gd")

var _a_shared = null

func _ready():
	_a_shared = _a_Shared.new(self)

func init(_p_entity):
	pass

func get_save_data():
	var data = _a_shared.get_save_data()
	var mat = get_material()
	if mat != null:
		mat = mat.duplicate(true)
	data["Material"] = mat
	
	return data

func load_data(p_data):
	_a_shared.load_data(p_data)
	set_material(p_data["Material"])

func load_data_init():
	pass
