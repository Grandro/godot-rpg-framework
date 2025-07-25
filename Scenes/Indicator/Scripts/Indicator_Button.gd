extends "res://Scenes/Indicator/Scripts/Indicator.gd"

signal select_pressed()

@onready var _a_Select = get_node("Select")

func _ready():
	super()
	_a_Select.pressed.connect(_on_Select_pressed)

func set_select_diabled(p_disabled):
	_a_Select.set_disabled(p_disabled)

func _on_Select_pressed():
	select_pressed.emit()
