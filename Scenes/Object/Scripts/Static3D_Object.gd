extends StaticBody3D
class_name Static3DObject

var _a_comph = CompHandler.new(self)

func _ready():
	_a_comph.register_comps()

func comph():
	return _a_comph

func get_save_data():
	var data = {}
	data["Visible"] = is_visible()
	data["Transform"] = get_transform()
	
	return data

func load_data(p_data):
	set_visible(p_data["Visible"])
	set_transform(p_data["Transform"])

func load_data_init():
	pass
