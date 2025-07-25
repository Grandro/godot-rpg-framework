extends "res://Global_Scenes/Debug/Command_Edit/Scripts/Command_Base.gd"

@onready var _a_Key_Type = get_node("Window/Contents/Margin/VBox/VBox/Key_Type")
@onready var _a_Key = get_node("Window/Contents/Margin/VBox/VBox/Key")
@onready var _a_Process_Type = get_node("Window/Contents/Margin/VBox/VBox/Process_Type")
@onready var _a_Start_Idx = get_node("Window/Contents/Margin/VBox/VBox/Start_Idx")
@onready var _a_End_Idx = get_node("Window/Contents/Margin/VBox/VBox/End_Idx")
@onready var _a_Layer = get_node("Window/Contents/Margin/VBox/VBox/Layer")
@onready var _a_Fade_Out = get_node("Window/Contents/Margin/VBox/VBox/Fade_Out")

func _ready():
	_a_OK = get_node("Window/Contents/Margin/VBox/HBox/OK")
	_a_Cancel = get_node("Window/Contents/Margin/VBox/HBox/Cancel")
	super()
	
	_a_Key_Type.selected.connect(_on_Key_Type_selected)
	_a_Key.selected.connect(_on_Key_selected)
	
	_a_Key_Type.update_options()
	_a_Process_Type.update_options()

func open(p_instance, p_data, p_res_data):
	super(p_instance, p_data, p_res_data)
	
	_a_Window.show()
	show()

func _open_init(_p_res_data):
	_a_Key_Type.load_data_init()
	_selected_key_type_changed()
	_a_Key.load_data_init()
	_selected_key_changed()
	_a_Process_Type.load_data_init()
	_a_Fade_Out.load_data_init()

func _open_load(p_data, _p_res_data):
	_a_Key_Type.load_data(p_data["Key_Type"])
	_selected_key_type_changed()
	_a_Key.load_data(p_data["Key"])
	_selected_key_changed()
	_a_Process_Type.load_data(p_data["Process_Type"])
	_a_Fade_Out.load_data(p_data["Fade_Out"])

func _selected_key_type_changed():
	var key_type = _a_Key_Type.get_selected_key()
	_a_Key.set_key_type(key_type)
	_a_Key.update_options()

func _selected_key_changed():
	var key_type = _a_Key_Type.get_selected_key()
	var dialogues_data = Databases.get_global_map_data("Dialogues", key_type)
	var key = _a_Key.get_selected_key()
	var dialogue_data = dialogues_data[key]["Data"]
	var max_idx = dialogue_data.size() - 1
	_a_Start_Idx.set_value_max(max_idx)
	_a_End_Idx.set_value_max(max_idx)

func _get_save_data():
	var data = {}
	data["Key_Type"] = _a_Key_Type.get_save_data()
	data["Key"] = _a_Key.get_save_data()
	data["Process_Type"] = _a_Process_Type.get_save_data()
	data["Start_Idx"] = _a_Start_Idx.get_save_data()
	data["End_Idx"] = _a_End_Idx.get_save_data()
	data["Layer"] = _a_Layer.get_save_data()
	data["Fade_Out"] = _a_Fade_Out.get_save_data()
	
	return data

func _on_Key_Type_selected():
	_selected_key_type_changed()

func _on_Key_selected():
	_selected_key_changed()
