extends "res://Global_Scenes/Main_Menu/Menus/Scripts/Menu_Base.gd"

@onready var _a_Menu_Icons = get_node("VBox/Menu_Icons")
@onready var _a_Back = get_node("Back")

func _ready():
	_a_Back.select_pressed.connect(_on_Back_select_pressed)
	
	_init_menu_icons(_a_Menu_Icons)

func _on_Back_select_pressed():
	close()
