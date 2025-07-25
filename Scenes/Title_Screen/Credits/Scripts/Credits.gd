extends Control

@onready var _a_Back = get_node("Back")
@onready var _a_Godot_Engine_Text = get_node("Margin/VBox/Scroll/VBox/Godot_Engine/Text")

func _ready():
	_a_Back.select_pressed.connect(_on_Back_select_pressed)
	
	var license_text = Engine.get_license_text()
	_a_Godot_Engine_Text.set_text(license_text)

func _unhandled_input(p_event):
	if p_event.is_action_pressed("ui_cancel"):
		_close()

func open():
	show()

func _close():
	hide()

func _on_Back_select_pressed():
	_close()
