extends "res://Global_Scenes/Debug/Scenes/Value_Select/Scripts/Value_Select.gd"

@onready var _a_Value = get_node("Value")

func set_max_value_max(p_max_value):
	_a_Value.set_max_value_max(p_max_value)

func get_save_data():
	var data = super()
	data["Value"] = _a_Value.get_save_data()
	
	return data

func load_data(p_data):
	super(p_data)
	_a_Value.load_data(p_data["Value"])

func load_data_init():
	super()
	_a_Value.load_data_init()
