extends "res://Global_Scenes/Main_Menu/Sub_Menus/Options/Scripts/Option_Tab.gd"

@onready var _a_Keyboard_Layout = get_node("HSplit/Left/Keyboard_Layout")

func _ready():
	_a_Keyboard_Layout.selected.connect(_on_Keyboard_Layout_selected)
	
	_a_Keyboard_Layout.update_options()

func load_data(p_data):
	_a_Keyboard_Layout.load_data(p_data["Keyboard_Layout"])

func _on_Keyboard_Layout_selected():
	var keyboard_layout = _a_Keyboard_Layout.get_selected_key()
	Global_Data.set_options_controls_keyboard_layout(keyboard_layout)
