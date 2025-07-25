extends "res://Global_Scenes/Debug/Command_Edit/Scripts/Command_Preview_Object_Path.gd"

@onready var _a_Type = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Type")
@onready var _a_Interpolate = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Interpolate")
@onready var _a_Speed = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Speed")
@onready var _a_Trans_Type = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Trans_Type")
@onready var _a_Ease_Type = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Ease_Type")
@onready var _a_End_Object = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/End_Object")
@onready var _a_Change_Camera = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Change_Camera")
@onready var _a_Wait_Finish = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Wait_Finish")

var _a_type = "" # Move_Route/Object_To_Object/Object_To_Point

func _ready():
	_a_Point = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Point")
	super()
	
	_a_Type.selected.connect(_on_Type_selected)
	_a_Interpolate.pressed.connect(_on_Interpolate_pressed)
	_a_End_Object.selected.connect(_on_End_Object_selected)
	
	_a_Type.update_options()
	_a_Speed.update_options()
	_a_Trans_Type.update_options()
	_a_Ease_Type.update_options()
	_create_end_objects()

func update_grid():
	super()
	match _a_type:
		"Object_To_Point":
			if _a_Point.is_point_visible():
				_a_dimensions.update_point()

func open(p_instance, p_data, p_res_data):
	await super(p_instance, p_data, p_res_data)
	
	var point = _a_Point.get_point_instance()
	_a_preview_scene.add_child(point)
	
	# Check if selected camera was chosen by Move_Free_Camera
	var has_object_free_camera = false
	if p_res_data.has("Misc"):
		if p_res_data["Misc"].has("Free_Camera"):
			if p_res_data["Misc"]["Free_Camera"].has("Object"):
				has_object_free_camera = true
	
	if has_object_free_camera && p_data.is_empty():
		var key = p_res_data["Misc"]["Free_Camera"]["Object"]
		_a_Object.select(key)
		_selected_object_changed_type("Start")
	
	_selected_type_changed.call_deferred()
	_interpolate_pressed_changed()
	
	_a_Window.show()
	show()

func _open_init(p_res_data):
	super(p_res_data)
	_a_Type.load_data_init()
	_a_Type.select("Move_Route")
	_a_Interpolate.load_data_init()
	_a_Speed.load_data_init()
	_a_Speed.select("Normal")
	_a_Trans_Type.load_data_init()
	_a_Trans_Type.select("Linear")
	_a_Ease_Type.load_data_init()
	_a_Ease_Type.select("In_Out")
	_a_Object.load_data_init()
	_select_default_object(p_res_data)
	_selected_object_changed()
	_a_End_Object.load_data_init()
	_a_Point.load_data_init()
	_a_Change_Camera.load_data_init()
	_a_Wait_Finish.load_data_init()

func _open_load(p_data, p_res_data):
	super(p_data, p_res_data)
	_a_Type.load_data(p_data["Type"])
	_a_Interpolate.load_data(p_data["Interpolate"])
	_a_Speed.load_data(p_data["Speed"])
	_a_Trans_Type.load_data(p_data["Trans_Type"])
	_a_Ease_Type.load_data(p_data["Ease_Type"])
	_a_Object.load_data(p_data["Start_Object"])
	_selected_object_changed_type("Start")
	_a_End_Object.load_data(p_data["End_Object"])
	_a_Point.load_data(p_data["Point"])
	_a_dimensions.update_point()
	_a_Change_Camera.load_data(p_data["Change_Camera"])
	_a_Wait_Finish.load_data(p_data["Wait_Finish"])

func _create_objects():
	super()
	if _a_Object.get_count() > 0:
		_selected_object_changed_type("Start")

func _create_end_objects():
	_a_End_Object.set_viewport(_a_preview_vp)
	_a_End_Object.update_options()
	if _a_End_Object.get_count() > 0:
		_selected_object_changed_type("End")

func _selected_type_changed():
	var type = _a_Type.get_selected_key()
	match type:
		"Move_Route":
			_a_Path_Points.show()
			_a_Object.hide()
			_a_End_Object.hide()
			_a_Point.hide()
			_a_Change_Camera.hide()
			
			_a_gen_path.show()
			_a_Point.set_point_visible(false)
		
		"Object_To_Object":
			var interpolate_pressed = _a_Interpolate.is_pressed()
			_a_Path_Points.hide()
			_a_Object.set_visible(interpolate_pressed)
			_a_End_Object.show()
			_a_Point.hide()
			_a_Change_Camera.show()
			
			_a_gen_path.hide()
			_a_Point.set_point_visible(false)
		
		"Object_To_Point":
			var interpolate_pressed = _a_Interpolate.is_pressed()
			_a_Path_Points.hide()
			_a_Object.set_visible(interpolate_pressed)
			_a_End_Object.hide()
			_a_Point.show()
			_a_Change_Camera.hide()
			
			if _a_Point.is_point_visible():
				_a_dimensions.update_point()
			_a_gen_path.hide()
			_a_Point.set_point_visible(true)
	
	_a_type = type

func _interpolate_pressed_changed():
	var pressed = _a_Interpolate.is_pressed()
	_a_Speed.set_visible(pressed)
	_a_Trans_Type.set_visible(pressed)
	_a_Ease_Type.set_visible(pressed)
	if _a_type != "Move_Route":
		_a_Object.set_visible(pressed)
	_a_Wait_Finish.set_visible(pressed)

func _selected_object_changed_type(p_type):
	#if _a_object != null:
	#	_a_object.set_material(null)
	
	var selected = null
	match p_type:
		"Start": selected = _a_Object.get_selected_value()
		"End": selected = _a_End_Object.get_selected_value()
	
	#selected.set_material(_e_outline_shader)
	var selected_pos = selected.get_position()
	_a_free_camera.set_position(selected_pos)
	_a_free_camera.comph().call_comp("Camera", "make_current_")
	
	_a_object = selected

func _handle_mouse_left(p_point_vec):
	match _a_type:
		"Move_Route":
			super(p_point_vec)
		
		"Object_To_Point":
			var curr_point_vec = _a_Point.get_point_vec()
			if curr_point_vec == p_point_vec && _a_Point.is_point_visible():
				_a_Point.set_point_visible(false)
			else:
				_a_Point.set_point_vec(p_point_vec)
				_a_dimensions.update_point()
				_a_Point.set_point_visible(true)

func _get_save_data():
	var data = super()
	data["Object"]["Value"] = "$Free_Camera"
	data["Start_Object"] = _a_Object.get_save_data()
	data["End_Object"] = _a_End_Object.get_save_data()
	data["Type"] = _a_Type.get_save_data()
	data["Interpolate"] = _a_Interpolate.get_save_data()
	data["Speed"] = _a_Speed.get_save_data()
	data["Trans_Type"] = _a_Trans_Type.get_save_data()
	data["Ease_Type"] = _a_Ease_Type.get_save_data()
	data["Point"] = _a_Point.get_save_data()
	data["Change_Camera"] = _a_Change_Camera.get_save_data()
	data["Wait_Finish"] = _a_Wait_Finish.get_save_data()
	
	return data

func _adjust_object_properties(p_properties):
	p_properties["$Main"] = {}
	
	match _a_type:
		"Move_Route":
			super(p_properties)
		
		"Object_To_Object":
			var end_object = _a_End_Object.get_selected_value()
			var end_object_key = _a_End_Object.get_selected_key()
			var pos = end_object.get_position()
			if end_object_key != "$Free_Camera":
				var camera = end_object.comph().get_comp("Camera")
				pos += camera.get_position()
			p_properties["$Main"]["position"] = pos
		
		"Object_To_Point":
			if _a_Point.is_point_visible():
				var point = _a_Point.get_point_vec()
				var pos = _grid_point_to_pos(point)
				p_properties["$Main"]["position"] = pos

func _on_Type_selected():
	_selected_type_changed()

func _on_Interpolate_pressed():
	_interpolate_pressed_changed()

func _on_Object_selected():
	_selected_object_changed_type("Start")

func _on_End_Object_selected():
	_selected_object_changed_type("End")
