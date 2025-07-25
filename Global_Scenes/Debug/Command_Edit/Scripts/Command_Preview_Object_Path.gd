extends "res://Global_Scenes/Debug/Command_Edit/Scripts/Command_Preview_Object.gd"

@export var _e_selected_color: Color = Color(1.0, 0.84, 0.0)
@export var _e_normal_color: Color = Color.WHITE

const _a_PATH_PATH = "res://Global_Scenes/Debug/Sprites/Path/%s.png"

@onready var _a_Path_Points = get_node("Window/Contents/Margin/HBox/Path_Points")

var _a_path_point = null # Currently selected path point

func _ready():
	super()
	_a_Path_Points.entry_moved.connect(_on_Path_Points_entry_moved)
	_a_Path_Points.entry_select_pressed.connect(_on_Path_Points_entry_select_pressed)
	_a_Path_Points.entry_deleting.connect(_on_Path_Points_entry_deleting)

func open(p_instance, p_data, p_res_data):
	await _a_dimensions.nav_map_ready
	super(p_instance, p_data, p_res_data)

func close():
	_a_Path_Points.queue_free()
	super()

func _color_selected_path_point(p_color):
	if is_instance_valid(_a_path_point):
		var nav_mesh_path_point = _a_path_point.get_point()
		var instance = _a_gen_path.get_sprite_instance(nav_mesh_path_point)
		instance.set_modulate(p_color)

func _handle_mouse_left(p_point):
	if _a_gen_path.has_path_point(p_point):
		_a_gen_path.remove_path_point(p_point)
	else:
		_a_gen_path.add_path_point(p_point)

func _adjust_object_properties(p_properties):
	p_properties["$Main"] = {}
	
	var nav_mesh_path_points = _a_gen_path.get_nav_mesh_path_points()
	if !nav_mesh_path_points.is_empty():
		var point = nav_mesh_path_points[-1]
		var pos = _grid_point_to_pos(point)
		p_properties["$Main"]["position"] = pos

func _on_Preview_gui_input(p_event):
	super(p_event)
	
	if p_event.is_action_pressed("Mouse_Left"):
		var global_pos = _a_dimensions.get_global_mouse_pos()
		if global_pos:
			var point = _pos_to_grid_point(global_pos)
			_handle_mouse_left(point)

func _on_Gen_Path_path_updated():
	_a_Path_Points.clear_entries()
	
	var nav_mesh_path_points = _a_gen_path.get_nav_mesh_path_points()
	var sprite_names = _a_gen_path.get_sprite_names()
	var i = 0
	for nav_mesh_path_point in nav_mesh_path_points:
		var sprite_name = sprite_names[i]
		var texture = load(_a_PATH_PATH % sprite_name)
		var instance = _a_Path_Points.instantiate_entry_(nav_mesh_path_point)
		instance.set_type_texture.call_deferred(texture)
		_a_Path_Points.add_entry(instance)
		
		i += 1

func _on_Path_Points_entry_moved(_p_old_idx, _p_new_idx):
	var nav_mesh_path_points = _a_Path_Points.get_points()
	var path_points = []
	for nav_mesh_path_point in nav_mesh_path_points:
		var path_point = _a_gen_path.get_path_point(nav_mesh_path_point)
		path_points.push_back(path_point)
	
	_a_gen_path.set_path_points(path_points)

func _on_Path_Points_entry_select_pressed(p_instance):
	var nav_mesh_path_point = p_instance.get_point()
	var pos = _grid_point_to_pos(nav_mesh_path_point)
	_a_free_camera.set_position(pos)
	
	_color_selected_path_point(_e_normal_color)
	
	_a_path_point = p_instance
	_color_selected_path_point(_e_selected_color)

func _on_Path_Points_entry_deleting(p_instance):
	var nav_mesh_path_point = p_instance.get_point()
	var path_point = _a_gen_path.get_path_point(nav_mesh_path_point)
	_a_gen_path.remove_path_point(path_point)
