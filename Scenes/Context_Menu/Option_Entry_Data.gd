extends Resource
class_name ContextMenuOptionEntryData

@export var _e_hsep: bool = false # If true, ignore all others
@export var _e_icon_texture: Texture2D = null
@export var _e_show_left: bool = true
@export var _e_show_right: bool = false
@export var _e_visible: bool = true
@export var _e_disabled: bool = false
@export var _e_options: Dictionary = {} # Match key to ContextMenuOptionEntryData
@export var _e_options_order: Array[String] = []

func get_hsep():
	return _e_hsep

func get_icon_texture():
	return _e_icon_texture

func get_show_left():
	return _e_show_left

func get_show_right():
	return _e_show_right

func set_visible(p_visible):
	_e_visible = p_visible

func get_visible():
	return _e_visible

func set_disabled(p_disabled):
	_e_disabled = p_disabled

func get_disabled():
	return _e_disabled

func set_options(p_options):
	_e_options = p_options

func get_options():
	return _e_options

func get_options_order():
	return _e_options_order
