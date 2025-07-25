extends Control

@onready var _a_Image = get_node("VBox/Margin/Image")

var _a_key = ""

func set_key(p_key):
	_a_key = p_key

func get_key():
	return _a_key

func set_texture(p_texture):
	_a_Image.set_texture(p_texture)

func get_texture():
	return _a_Image.get_texture()
