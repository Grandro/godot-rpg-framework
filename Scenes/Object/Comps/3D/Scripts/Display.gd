extends Sprite3D

@export var _e_billboard : bool = false

var _a_Shared = preload("res://Scenes/Object/Comps/Display/Scripts/Shared.gd")

var _a_shared = null

var _a_init_rotation = Vector3.ZERO

func _ready():
	_a_shared = _a_Shared.new(self)
	
	_a_init_rotation = get_rotation_degrees()
	set_billboard(_e_billboard)

func _process(_p_delta):
	update_billboard_rotation()

func init(_p_entity):
	pass

func update_billboard_rotation():
	var camera = get_viewport().get_camera_3d()
	var pos = Vector3.ZERO
	pos.x = camera.global_position.x
	pos.y = global_position.y
	pos.z = camera.global_position.z
	look_at(pos, Vector3.UP, true)

func set_billboard(p_billboard):
	_e_billboard = p_billboard
	set_process(p_billboard)
	
	if p_billboard:
		update_billboard_rotation()
	else:
		set_rotation_degrees(_a_init_rotation)

func get_billboard():
	return _e_billboard

func get_save_data():
	var data = _a_shared.get_save_data()
	data["Transform"] = get_transform()
	data["Billboard"] = _e_billboard
	data["Region_Rect"] = get_region_rect()
	data["Material"] = Data_Parser.parse_object(material_override)
	
	return data

func load_data(p_data):
	_a_shared.load_data(p_data)
	var mat = Data_Parser.unparse_object(p_data["Material"])
	set_transform(p_data["Transform"])
	set_billboard(p_data["Billboard"])
	set_region_rect(p_data["Region_Rect"])
	set_material_override(mat)

func load_data_init():
	pass
