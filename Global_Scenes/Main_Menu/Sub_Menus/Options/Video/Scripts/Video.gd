extends "res://Global_Scenes/Main_Menu/Sub_Menus/Options/Scripts/Option_Tab.gd"

@onready var _a_VSync_Mode = get_node("HSplit/Left/VSync_Mode")
@onready var _a_Window_Size = get_node("HSplit/Left/Window_Size")
@onready var _a_Window_Mode = get_node("HSplit/Left/Window_Mode")

func _ready():
	_a_VSync_Mode.selected.connect(_on_VSync_Mode_selected)
	_a_Window_Size.selected.connect(_on_Window_Size_selected)
	_a_Window_Mode.selected.connect(_on_Window_Mode_selected)
	
	_a_VSync_Mode.update_options()
	_a_Window_Size.update_options()
	_a_Window_Mode.update_options()

func load_data(p_data):
	_a_VSync_Mode.load_data(p_data["VSync_Mode"])
	_a_Window_Size.load_data(p_data["Window_Size"])
	_a_Window_Mode.load_data(p_data["Window_Mode"])

func _on_VSync_Mode_selected():
	var vsync_mode = _a_VSync_Mode.get_selected_key()
	Global_Data.set_options_video_vsync_mode(vsync_mode)

func _on_Window_Size_selected():
	var window_size = _a_Window_Size.get_selected_key()
	Global_Data.set_options_video_window_size(window_size)

func _on_Window_Mode_selected():
	var window_mode = _a_Window_Mode.get_selected_key()
	Global_Data.set_options_video_window_mode(window_mode)
