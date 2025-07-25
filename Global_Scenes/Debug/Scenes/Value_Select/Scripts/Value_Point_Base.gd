extends "res://Global_Scenes/Debug/Scenes/Value_Select/Scripts/Value_Select.gd"

@export var _e_type_texture = preload("res://Global_Scenes/Debug/Sprites/Path/End.png")
@export var _e_point_scene : PackedScene = null

@onready var _a_Value_Text = get_node("Value/Margin/Text")
@onready var _a_Value_Type = get_node("Value/Margin/Type")

var _a_point = null # Point instance displayed on map
var _a_point_vec = null # Coords of _a_point in grid

func _ready():
	super()
	_a_Value_Type.set_texture(_e_type_texture)
	
	_instantiate_point()
	_a_point.hide()

func _instantiate_point():
	_a_point = _e_point_scene.instantiate()
	_a_point.set_texture(_e_type_texture)

func _update_value_text():
	if !is_point_visible():
		_a_Value_Text.set_text("-")

func get_point_instance():
	return _a_point

func set_point_vec(p_point_vec):
	_a_point_vec = p_point_vec

func get_point_vec():
	return _a_point_vec

func get_point_pos():
	return _a_point.get_position()

func set_point_visible(p_visible):
	_a_point.set_visible(p_visible)
	_update_value_text()

func is_point_visible():
	return _a_point.is_visible()

func get_save_data():
	var data = super()
	data["Selected"] = is_point_visible()
	data["Value"] = get_point_vec()
	
	return data

func load_data(p_data):
	super(p_data)
	
	var selected = p_data["Selected"]
	set_point_vec(p_data["Value"])
	set_point_visible(selected)

func load_data_init():
	super()
	_a_Value_Text.set_text("-")
