extends "res://Global_Scenes/Debug/Command_Edit/Scripts/Command_Preview_Object.gd"

@onready var _a_Disable = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Disable")

func open(p_instance, p_data, p_res_data):
	super(p_instance, p_data, p_res_data)
	
	_selected_object_changed()
	
	_a_Window.show()
	show()

func _open_init(p_res_data):
	super(p_res_data)
	_a_Object.load_data_init()
	_select_default_object(p_res_data)
	_selected_object_changed()
	_a_Disable.load_data_init()

func _open_load(p_data, p_res_data):
	super(p_data, p_res_data)
	_a_Object.load_data(p_data["Object"])
	_selected_object_changed()
	_a_Disable.load_data(p_data["Disable"])

func _selected_object_changed():
	super()
	_a_object = _a_Object.get_selected_value()

func _get_save_data():
	var data = super()
	data["Disable"] = _a_Disable.get_save_data()
	
	return data
