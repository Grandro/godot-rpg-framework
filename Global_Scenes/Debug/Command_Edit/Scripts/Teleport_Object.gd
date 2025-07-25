extends "res://Global_Scenes/Debug/Command_Edit/Scripts/Command_Preview_Object.gd"

func _ready():
	_a_Point = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Point")
	super()

func update_grid():
	super()
	if _a_Point.is_point_visible():
		_a_dimensions.update_point()

func open(p_instance, p_data, p_res_data):
	super(p_instance, p_data, p_res_data)
	
	var point = _a_Point.get_point_instance()
	_a_preview_scene.add_child(point)
	
	_a_Window.show()
	show()

func _open_init(p_res_data):
	super(p_res_data)
	_a_Object.load_data_init()
	_select_default_object(p_res_data)
	_selected_object_changed()
	_a_Point.load_data_init()

func _open_load(p_data, p_res_data):
	super(p_data, p_res_data)
	_a_Object.load_data(p_data["Object"])
	_selected_object_changed()
	_a_Point.load_data(p_data["Point"])
	_a_dimensions.update_point()
	
	var point_pos = _a_Point.get_point_pos()
	_a_free_camera.set_position(point_pos)

func _selected_object_changed():
	super()
	_a_object = _a_Object.get_selected_value()

func _get_save_data():
	var data = super()
	data["Point"] = _a_Point.get_save_data()
	
	return data

func _adjust_object_properties(p_properties):
	if !_a_Point.is_point_visible():
		return
	
	p_properties["$Main"] = {}
	
	var pos = _a_Point.get_point_pos()
	p_properties["$Main"]["position"] = pos

func _on_Preview_gui_input(p_event):
	super(p_event)
	
	if p_event.is_action_pressed("Mouse_Left"):
		var global_pos = _a_dimensions.get_global_mouse_pos()
		if global_pos:
			var point = _pos_to_grid_point(global_pos)
			var curr_point = _a_Point.get_point_vec()
			if curr_point == point && _a_Point.is_point_visible():
				_a_Point.set_point_visible(false)
			else:
				_a_Point.set_point_vec(point)
				_a_dimensions.update_point()
				_a_Point.set_point_visible(true)
