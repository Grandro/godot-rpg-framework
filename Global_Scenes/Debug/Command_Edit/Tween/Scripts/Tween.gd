extends "res://Global_Scenes/Debug/Command_Edit/Scripts/Command_Preview_Object.gd"

@export var _e_point_scene : PackedScene = null

@onready var _a_Comp = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Comp")
@onready var _a_Property = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Property")
@onready var _a_Interpolate = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Interpolate")
@onready var _a_Duration = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Duration")
@onready var _a_Trans_Type = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Trans_Type")
@onready var _a_Ease_Type = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Ease_Type")
@onready var _a_Start_Value = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Start_Value")
@onready var _a_End_Value = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/End_Value")
@onready var _a_Wait_Finish = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Wait_Finish")

var _a_tween = null
var _a_start_point = null # Start point displayed on map
var _a_end_point = null # End point displayed on map
var _a_comp = "" # Selected comp to reset to default value
var _a_property = "" # Selected property to reset to default value

func _ready():
	super()
	_a_Comp.selected.connect(_on_Comp_selected)
	_a_Property.selected.connect(_on_Property_selected)
	_a_Interpolate.pressed.connect(_on_Interpolate_pressed)
	_a_Duration.value_changed.connect(_on_Duration_value_changed)
	_a_Trans_Type.selected.connect(_on_Trans_Type_selected)
	_a_Ease_Type.selected.connect(_on_Ease_Type_selected)
	_a_Start_Value.value_changed.connect(_on_Start_value_changed)
	_a_End_Value.value_changed.connect(_on_End_value_changed)
	
	_a_Trans_Type.update_options()
	_a_Ease_Type.update_options()

func update_grid():
	super()
	if is_instance_valid(_a_start_point):
		var start_point_vec = _a_dimensions.get_start_point_vec()
		_update_start_point(start_point_vec)
	if is_instance_valid(_a_end_point):
		var end_point_vec = _a_dimensions.get_end_point_vec()
		_update_end_point(end_point_vec)

func open(p_instance, p_data, p_res_data):
	super(p_instance, p_data, p_res_data)
	
	_a_Window.show()
	show()

func _open_init(p_res_data):
	super(p_res_data)
	_a_Object.load_data_init()
	_select_default_object(p_res_data)
	_selected_object_changed()
	_a_Comp.load_data_init()
	_selected_comp_changed(false)
	_a_Property.load_data_init()
	_a_Interpolate.load_data_init()
	_interpolate_changed()
	_a_Duration.load_data_init()
	_a_Trans_Type.load_data_init()
	_a_Ease_Type.load_data_init()
	_a_Start_Value.load_data_init()
	_a_End_Value.load_data_init()
	_a_Wait_Finish.load_data_init()
	_selected_property_changed()

func _open_load(p_data, p_res_data):
	super(p_data, p_res_data)
	_a_Object.load_data(p_data["Object"])
	_selected_object_changed()
	_a_Comp.load_data(p_data["Comp"])
	_selected_comp_changed(false)
	_a_Property.load_data(p_data["Property"])
	_a_Interpolate.load_data(p_data["Interpolate"])
	_interpolate_changed()
	_a_Duration.load_data(p_data["Duration"])
	_a_Trans_Type.load_data(p_data["Trans_Type"])
	_a_Ease_Type.load_data(p_data["Ease_Type"])
	_a_Start_Value.load_data(p_data["Start_Value"])
	_a_End_Value.load_data(p_data["End_Value"])
	_a_Wait_Finish.load_data(p_data["Wait_Finish"])
	_selected_property_changed()

func _update_start_point(p_pos):
	if !is_instance_valid(_a_start_point):
		_a_start_point = _e_point_scene.instantiate()
		_a_preview_scene.add_child(_a_start_point)
	
	_a_dimensions.update_start_point(p_pos)

func _update_end_point(p_pos):
	if !is_instance_valid(_a_end_point):
		_a_end_point = _e_point_scene.instantiate()
		_a_preview_scene.add_child(_a_end_point)
	
	_a_dimensions.update_end_point(p_pos)

func _update_tween():
	if _a_tween != null:
		_a_tween.kill()
	
	var interpolate = _a_Interpolate.is_pressed()
	var end_value = _a_End_Value.get_value()
	var comp = _a_object.comph().get_comp(_a_comp)
	if interpolate:
		var start_value = _a_Start_Value.get_value()
		if typeof(start_value) == TYPE_NIL:
			start_value = _get_object_revert_property_value(_a_object, _a_comp, _a_property)
		
		if typeof(start_value) != typeof(end_value):
			return
		
		var curr_value = comp.get(_a_property)
		if typeof(start_value) != typeof(curr_value):
			return
		
		var duration = _a_Duration.get_value()
		var trans_type_key = _a_Trans_Type.get_selected_key()
		var ease_type_key = _a_Ease_Type.get_selected_key()
		var trans_type = Global.convert_trans_type_key(trans_type_key)
		var ease_type = Global.convert_ease_type_key(ease_type_key)
		_a_tween = create_tween()
		_a_tween.set_trans(trans_type)
		_a_tween.set_ease(ease_type)
		_a_tween.tween_property(comp, _a_property, end_value, duration).from(start_value)
	else:
		comp.set(_a_property, end_value)

func _delete_start_point():
	if is_instance_valid(_a_start_point):
		_a_start_point.queue_free()

func _delete_end_point():
	if is_instance_valid(_a_end_point):
		_a_end_point.queue_free()

func _selected_object_changed():
	super()
	if _a_object != null:
		_revert_object_property(_a_object, _a_comp, _a_property)
	
	_a_object = _a_Object.get_selected_value()
	_a_Comp.set_object(_a_object)
	_a_Comp.update_options()
	_selected_comp_changed(false)

func _selected_comp_changed(p_reset):
	if p_reset && !_a_comp.is_empty():
		_revert_object_property(_a_object, _a_comp, _a_property)
	_a_comp = _a_Comp.get_selected_key()
	_a_Property.set_object(_a_object)
	_a_Property.set_comp(_a_comp)
	_a_Property.update_options()
	
	if _a_Property.has_key(_a_property):
		_a_Property.select(_a_property)
	_selected_property_changed()

func _selected_property_changed():
	if !_a_property.is_empty():
		_revert_object_property(_a_object, _a_comp, _a_property)
	
	var instance = _a_object.comph().get_comp(_a_comp)
	var property = _a_Property.get_selected_key()
	var curr_value = instance.get(property)
	_set_object_revert_property_value(_a_object, _a_comp, property, curr_value)
	
	var start_value = _a_Start_Value.get_value()
	var end_value = _a_End_Value.get_value()
	if typeof(start_value) != typeof(curr_value) && typeof(start_value) != TYPE_NIL:
		_a_Start_Value.set_value(curr_value)
	if typeof(end_value) != typeof(curr_value):
		_a_End_Value.set_value(curr_value)
	
	_a_property = property
	
	_update_tween()

func _interpolate_changed():
	var pressed = _a_Interpolate.is_pressed()
	_a_Duration.set_visible(pressed)
	_a_Trans_Type.set_visible(pressed)
	_a_Ease_Type.set_visible(pressed)
	_a_Start_Value.set_visible(pressed)
	_a_Wait_Finish.set_visible(pressed)
	if is_instance_valid(_a_start_point):
		_a_start_point.set_visible(pressed)
	
	_update_tween()

func get_start_point_instance():
	return _a_start_point

func get_end_point_instance():
	return _a_end_point

func _is_start_focused():
	var focus_owner = get_viewport().gui_get_focus_owner()
	if focus_owner == null:
		return false
	if _a_Start_Value.is_ancestor_of(focus_owner):
		return true
	
	return false

func _is_end_focused():
	var focus_owner = get_viewport().gui_get_focus_owner()
	if focus_owner == null:
		return false
	if _a_End_Value.is_ancestor_of(focus_owner):
		return true
	
	return false

func _get_save_data():
	var data = super()
	_adjust_object_properties(data["Object"]["Properties"])
	
	data["Comp"] = _a_Comp.get_save_data()
	data["Property"] = _a_Property.get_save_data()
	data["Interpolate"] = _a_Interpolate.get_save_data()
	data["Duration"] = _a_Duration.get_save_data()
	data["Trans_Type"] = _a_Trans_Type.get_save_data()
	data["Ease_Type"] = _a_Ease_Type.get_save_data()
	data["Start_Value"] = _a_Start_Value.get_save_data()
	data["End_Value"] = _a_End_Value.get_save_data()
	data["Wait_Finish"] = _a_Wait_Finish.get_save_data()
	
	return data

func _adjust_object_properties(p_properties):
	var end_value = _a_End_Value.get_value()
	p_properties[_a_comp] = {}
	p_properties[_a_comp][_a_property] = end_value

func _on_Preview_gui_input(p_event):
	super(p_event)
	
	if p_event.is_action_pressed("Mouse_Left"):
		var global_pos = _a_dimensions.get_global_mouse_pos()
		if global_pos:
			var point = _pos_to_grid_point(global_pos)
			var pos = _grid_point_to_pos(point)
			if _is_start_focused():
				_a_Start_Value.set_value(pos)
			if _is_end_focused():
				_a_End_Value.set_value(pos)

func _on_Comp_selected():
	_selected_comp_changed(true)

func _on_Property_selected():
	_selected_property_changed()

func _on_Interpolate_pressed():
	_interpolate_changed()

func _on_Duration_value_changed(_p_value):
	_update_tween()

func _on_Trans_Type_selected():
	_update_tween()

func _on_Ease_Type_selected():
	_update_tween()

func _on_Start_value_changed(p_value):
	if _a_dimensions.is_value_vector(p_value):
		_update_start_point(p_value)
	else:
		_delete_start_point()
	
	_update_tween()

func _on_End_value_changed(p_value):
	if _a_dimensions.is_value_vector(p_value):
		_update_end_point(p_value)
	else:
		_delete_end_point()
	
	_update_tween()
