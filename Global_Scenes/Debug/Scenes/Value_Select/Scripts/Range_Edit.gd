extends "res://Global_Scenes/Debug/Scenes/Range_Edit/Scripts/Range_Edit.gd"

@onready var _a_Min_Var_Select = get_node("Min/Var_Select")
@onready var _a_Max_Var_Select = get_node("Max/Var_Select")

func _ready():
	super()
	_a_Min_Var_Select.active_toggled.connect(_on_Var_Select_active_toggled.bind(_a_Min))
	_a_Max_Var_Select.active_toggled.connect(_on_Var_Select_active_toggled.bind(_a_Max))

func get_save_data():
	var data = {}
	data["Min"] = _get_save_data(_a_Min_Var_Select, _a_Min)
	data["Max"] = _get_save_data(_a_Max_Var_Select, _a_Max)
	
	return data

func _get_save_data(p_var_select, p_value):
	var data = {}
	if p_var_select.is_active():
		data["Type"] = "Var"
	else:
		data["Type"] = "Value"
	data["Var"] = p_var_select.get_save_data()
	data["Value"] = p_value.get_value()
	
	return data

func load_data(p_data):
	_load_data(p_data["Min"], _a_Min_Var_Select, _a_Min)
	_load_data(p_data["Max"], _a_Max_Var_Select, _a_Max)
	_a_Min_Var_Select.load_data(p_data["Min"]["Var"])
	_a_Max_Var_Select.load_data(p_data["Max"]["Var"])

func _load_data(p_data, p_var_select, p_value):
	p_var_select.load_data(p_data["Var"])
	p_value.set_value(p_data["Value"])

func load_data_init():
	_a_Min_Var_Select.load_data_init()
	_a_Max_Var_Select.load_data_init()

func _on_Var_Select_active_toggled(p_toggled, p_instance):
	p_instance.set_editable(!p_toggled)
