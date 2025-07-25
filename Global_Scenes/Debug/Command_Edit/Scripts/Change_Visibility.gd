extends "res://Global_Scenes/Debug/Command_Edit/Scripts/Command_Preview_Object.gd"

@onready var _a_Visible = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Visible")

func _ready():
	super()
	_a_Visible.pressed.connect(_on_Visible_pressed)

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
	_a_Visible.load_data_init()

func _open_load(p_data, p_res_data):
	super(p_data, p_res_data)
	_a_Object.load_data(p_data["Object"])
	_selected_object_changed()
	_a_Visible.load_data(p_data["Visible"])

func _selected_object_changed():
	super()
	if _a_object != null:
		_revert_object_property(_a_object, "$Main", "visible")
	
	var instance = _a_Object.get_selected_value()
	var curr_visible = instance.is_visible()
	_set_object_revert_property_value(instance, "$Main", "visible", curr_visible)
	var is_visible_ = _a_Visible.is_pressed()
	instance.set_visible(is_visible_)
	
	_a_object = instance

func _get_save_data():
	var data = super()
	data["Visible"] = _a_Visible.get_save_data()
	
	return data

func _adjust_object_properties(p_properties):
	p_properties["$Main"] = {}
	p_properties["$Main"]["visible"] = _a_object.is_visible()

func _on_Visible_pressed():
	var is_visible_ = _a_Visible.is_pressed()
	_a_object.set_visible(is_visible_)
