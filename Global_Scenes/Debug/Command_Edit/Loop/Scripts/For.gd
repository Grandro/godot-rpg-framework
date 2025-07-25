extends "res://Global_Scenes/Debug/Command_Edit/Scripts/Menu_Base.gd"

@onready var _a_Idx = get_node("VBox/Idx")
@onready var _a_Start = get_node("VBox/Start")
@onready var _a_End = get_node("VBox/End")
@onready var _a_Step = get_node("VBox/Step")

func open(p_data, p_res_data):
	_a_Idx.set_taken_idx_ords(p_res_data["Misc"]["For_Loop_Idx_Ords"])
	if p_data.is_empty():
		_open_init()
	else:
		_open_load(p_data)
	
	show()

func _open_init():
	_a_Idx.load_data_init()
	_a_Start.load_data_init()
	_a_End.load_data_init()
	_a_Step.load_data_init()

func _open_load(p_data):
	_a_Idx.load_data(p_data["Idx"])
	_a_Start.load_data(p_data["Start"])
	_a_End.load_data(p_data["End"])
	_a_Step.load_data(p_data["Step"])

func get_save_data():
	var data = {}
	data["Idx"] = _a_Idx.get_save_data()
	data["Start"] = _a_Start.get_save_data()
	data["End"] = _a_End.get_save_data()
	data["Step"] = _a_Step.get_save_data()
	
	return data
