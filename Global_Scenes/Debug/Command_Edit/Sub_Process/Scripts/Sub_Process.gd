extends "res://Global_Scenes/Debug/Command_Edit/Scripts/Command_Base.gd"

@onready var _a_ID = get_node("Window/Contents/Margin/VBox/ID")

func _ready():
	_a_OK = get_node("Window/Contents/Margin/VBox/Options/OK")
	_a_Cancel = get_node("Window/Contents/Margin/VBox/Options/Cancel")
	super()

func open(p_instance, p_data, p_res_data):
	_a_ID.set_taken_idx_ords(p_res_data["Misc"]["Sub_Process_ID_Ords"])
	super(p_instance, p_data, p_res_data)
	
	_a_Window.show()
	show()

func _open_init(_p_res_data):
	_a_ID.load_data_init()

func _open_load(p_data, _p_res_data):
	_a_ID.load_data(p_data["ID"])

func _get_save_data():
	var data = {}
	data["ID"] = _a_ID.get_save_data()
	
	return data
