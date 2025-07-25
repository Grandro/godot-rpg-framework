extends HBoxContainer

@export var _e_key: String = ""
@export var _e_max_key: String = ""

const _a_ICON_PATH = "res://Global_Resources/Sprites/Icons/Stats/%s.png"

@onready var _a_Icon = get_node("Margin/Margin/HBox/Icon")
@onready var _a_Desc = get_node("Margin/Margin/HBox/Desc")
@onready var _a_Value_Curr = get_node("Value/Curr")
@onready var _a_Value_Slash = get_node("Value/Slash")
@onready var _a_Value_Max = get_node("Value/Max")

func _ready():
	var texture = load(_a_ICON_PATH % _e_key)
	_a_Icon.set_texture(texture)
	_a_Desc.set_text(_e_key)

func hide_max_value():
	_a_Value_Slash.hide()
	_a_Value_Max.hide()

func get_key():
	return _e_key

func get_max_key():
	return _e_max_key

func set_curr_value(p_value):
	_a_Value_Curr.set_text(str(p_value))

func set_max_value(p_value):
	_a_Value_Max.set_text(str(p_value))
