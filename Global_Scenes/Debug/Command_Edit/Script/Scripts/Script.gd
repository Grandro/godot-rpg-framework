extends "res://Global_Scenes/Debug/Command_Edit/Scripts/Command_Base.gd"

@onready var _a_Expression = get_node("Window/Contents/Margin/VBox/Expression")

func _ready():
	_a_OK = get_node("Window/Contents/Margin/VBox/HBox/OK")
	_a_Cancel = get_node("Window/Contents/Margin/VBox/HBox/Cancel")
	super()

func open(p_instance, p_data, p_res_data):
	_a_Expression.update_instances()
	super(p_instance, p_data, p_res_data)
	
	_a_Window.show()
	show()

func _open_init(_p_res_data):
	_a_Expression.load_data_init()

func _open_load(p_data, _p_res_data):
	_a_Expression.load_data(p_data)

func _get_save_data():
	return _a_Expression.get_save_data()
