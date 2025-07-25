extends Control

@onready var _a_Back = get_node("Back")

func _ready():
	_a_Back.select_pressed.connect(_on_Back_select_pressed)

func update_trans():
	pass

func close():
	hide()

func _on_Back_select_pressed():
	close()
