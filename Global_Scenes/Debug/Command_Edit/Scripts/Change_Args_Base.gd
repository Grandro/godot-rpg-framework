extends "res://Global_Scenes/Debug/Command_Edit/Scripts/Command_Preview_Object.gd"

@onready var _a_Type = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Type")
@onready var _a_Idx = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Idx")
@onready var _a_Value = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Value")

func _ready():
	super()
	_a_Type.update_options()

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
	_a_Type.load_data_init()
	_a_Idx.load_data_init()
	_a_Value.load_data_init()

func _open_load(p_data, p_res_data):
	super(p_data, p_res_data)
	_a_Object.load_data(p_data["Object"])
	_selected_object_changed()
	_a_Type.load_data(p_data["Type"])
	_a_Idx.load_data(p_data["Idx"])
	_a_Value.load_data(p_data["Value"])

func _selected_object_changed():
	super()
	
	_a_object = _a_Object.get_selected_value()
	var interactions_comp = _a_object.comph().get_comp("Interactions")
	var interaction_count = interactions_comp.get_child_count()
	_a_Idx.set_interaction_count(interaction_count)
	_a_Idx.update_options()

func _get_save_data():
	var data = super()
	data["Type"] = _a_Type.get_save_data()
	data["Idx"] = _a_Idx.get_save_data()
	data["Value"] = _a_Value.get_save_data()
	
	return data
