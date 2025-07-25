extends "res://Global_Scenes/Debug/Scenes/Value_Select/Scripts/Value_Select.gd"

signal selected()

@onready var _a_Select = get_node("Select")
@onready var _a_Item_Select = get_node("Canvas/Item_Select")

var _a_key = ""
var _a_stack = -1
var _a_image = null

func _ready():
	super()
	_a_Select.pressed.connect(_on_Select_pressed)
	_a_Item_Select.select_pressed.connect(_on_Item_Select_select_pressed)

func get_key():
	return _a_key

func get_stack_():
	return _a_stack

func get_save_data():
	var data = super()
	data["Value"] = _a_key
	data["Stack"] = _a_stack
	var image_path = ""
	if _a_image != null:
		image_path = _a_image.get_path()
	data["Image_Path"] = image_path
	
	return data

func load_data(p_data):
	super(p_data)
	
	_a_key = p_data["Value"]
	_a_stack = p_data["Stack"]
	var image_path = p_data["Image_Path"]
	if !image_path.is_empty():
		_a_image = load(image_path)
		_a_Select.set_texture_normal(_a_image)

func _on_Var_Select_active_toggled(p_toggled):
	_a_Select.set_disabled(p_toggled)

func _on_Select_pressed():
	_a_Item_Select.open(_a_key)

func _on_Item_Select_select_pressed(p_key, p_stack, p_image):
	_a_Select.set_texture_normal(p_image)
	_a_key = p_key
	_a_stack = p_stack
	_a_image = p_image
	selected.emit()
