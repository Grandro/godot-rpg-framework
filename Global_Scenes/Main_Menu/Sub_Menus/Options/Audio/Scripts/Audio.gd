extends "res://Global_Scenes/Main_Menu/Sub_Menus/Options/Scripts/Option_Tab.gd"

@onready var _a_Volume = get_node("HSplit/Left/Volume")

func load_data(p_data):
	_a_Volume.load_data(p_data["Volume"])
