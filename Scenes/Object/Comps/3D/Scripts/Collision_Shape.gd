extends CollisionShape3D

var _a_Shared = preload("res://Scenes/Object/Comps/Collision/Scripts/Shared.gd")

var _a_shared = null

func _ready():
	_a_shared = _a_Shared.new(self)

func init(p_entity):
	_a_shared.init(p_entity)

func get_save_data():
	var data = {}
	data["Transform"] = get_transform()
	data["Shape"] = Data_Parser.parse_object(shape)
	data["Disabled"] = is_disabled()
	
	return data

func load_data(p_data):
	var shape_ = Data_Parser.unparse_object(p_data["Shape"])
	set_transform(p_data["Transform"])
	set_shape(shape_)
	set_disabled(p_data["Disabled"])

func load_data_init():
	pass
