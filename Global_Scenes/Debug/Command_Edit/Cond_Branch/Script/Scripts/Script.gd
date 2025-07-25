extends "res://Global_Scenes/Debug/Command_Edit/Scripts/Menu_Base.gd"

@onready var _a_Expression = get_node("Expression")

func get_save_data():
	return _a_Expression.get_save_data()

func load_data(p_data):
	_a_Expression.update_instances()
	super(p_data)

func _load_data_init():
	_a_Expression.load_data_init()

func _load_data(p_data):
	_a_Expression.load_data(p_data)
