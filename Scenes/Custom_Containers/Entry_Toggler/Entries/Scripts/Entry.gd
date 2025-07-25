extends MarginContainer

signal select_toggled(p_instance)

@onready var _a_Select = get_node("Select")
@onready var _a_Texture = get_node("Margin/Texture")

func _ready():
	_a_Select.toggled.connect(_on_Select_toggled)

func set_select_text(p_text):
	_a_Select.set_text(p_text)

func set_select_disabled(p_disabled):
	_a_Select.set_disabled(p_disabled)

func set_select_pressed(p_pressed):
	_a_Select.set_pressed(p_pressed)

func set_texture(p_texture):
	_a_Texture.set_texture(p_texture)

func _on_Select_toggled(p_pressed):
	select_toggled.emit(p_pressed)
