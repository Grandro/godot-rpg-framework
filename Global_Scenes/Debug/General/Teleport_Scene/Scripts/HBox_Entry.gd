extends HBoxContainer

signal select_pressed()

@onready var _a_Select = get_node("Select")

func _ready():
	_a_Select.pressed.connect(_on_Select_pressed)

func set_select_text(p_text):
	_a_Select.set_text(p_text)

func _on_Select_pressed():
	select_pressed.emit()
