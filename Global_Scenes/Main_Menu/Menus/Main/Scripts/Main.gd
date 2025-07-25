extends "res://Global_Scenes/Main_Menu/Menus/Scripts/Menu_Base.gd"

@onready var _a_Menu_Icons = get_node("Margin/VBox/Menu_Icons")
@onready var _a_Back = get_node("Margin/VBox/HBox/Back")
@onready var _a_Titlescreen = get_node("Margin/VBox/HBox/Titlescreen")
@onready var _a_Coins = get_node("Margin/VBox/Coins/Text")

func _ready():
	_a_Back.select_pressed.connect(_on_Back_select_pressed)
	_a_Titlescreen.pressed.connect(_on_Titlescreen_pressed)
	
	var global_si = Global.get_singleton(self, "Global")
	var coins = global_si.get_coins()
	_a_Coins.set_text(str(coins))
	
	_init_menu_icons(_a_Menu_Icons)

func _on_Back_select_pressed():
	close()

func _on_Titlescreen_pressed():
	var messages_si = Global.get_singleton(self, "Messages")
	messages_si.show_proceed(tr("MAIN_MENU_UNSAVEDWARNING"), self)
	set_process_unhandled_input(false)

func MESSAGES_PROCEED(p_response):
	if p_response == "Yes":
		var main_menu_si = Global.get_singleton(self, "Main_Menu")
		var scene_manager_si = Global.get_singleton(self, "Scene_Manager")
		var title_screen_scene_path = Global.get_title_screen_scene_path()
		main_menu_si.close()
		scene_manager_si.change_scene_path(title_screen_scene_path)
	
	set_process_unhandled_input(true)
