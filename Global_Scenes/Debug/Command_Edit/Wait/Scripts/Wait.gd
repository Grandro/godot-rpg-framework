extends "res://Global_Scenes/Debug/Command_Edit/Scripts/Command_Base.gd"

@onready var _a_Time = get_node("Window/Contents/Margin/VBox/Time")

func _ready():
	_a_OK = get_node("Window/Contents/Margin/VBox/HBox/OK")
	_a_Cancel = get_node("Window/Contents/Margin/VBox/HBox/Cancel")
	super()

func open(p_instance, p_data, p_res_data):
	super(p_instance, p_data, p_res_data)
	
	_a_Window.show()
	show()

func _open_init(_p_res_data):
	_a_Time.load_data_init()

func _open_load(p_data, _p_res_data):
	_a_Time.load_data(p_data["Time"])

func _get_save_data():
	var data = {}
	data["Time"] = _a_Time.get_save_data()
	
	return data
