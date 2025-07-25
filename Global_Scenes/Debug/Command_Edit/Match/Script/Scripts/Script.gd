extends "res://Global_Scenes/Debug/Command_Edit/Match/Scripts/Menu_Match.gd"

@onready var _a_Expression = get_node("Expression")

func _ready():
	_a_Expression.update_instances()

func get_save_data():
	var data = super()
	data["Expression"] = _a_Expression.get_save_data()
	
	return data

func load_data(p_data):
	_a_Expression.update_instances()
	super(p_data)

func _load_data_init():
	_a_Expression.load_data_init()

func _load_data(p_data):
	super(p_data)
	_a_Expression.load_data(p_data["Expression"])
