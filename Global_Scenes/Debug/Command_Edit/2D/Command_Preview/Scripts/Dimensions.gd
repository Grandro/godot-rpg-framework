extends "res://Global_Scenes/Debug/Command_Edit/Command_Preview_Base/Scripts/Dimensions.gd"

signal nav_map_ready()

var _a_point = null

func _init(p_entity):
	super(p_entity)
	_a_point = _a_entity.get_point_instance()
	
	NavigationServer2D.map_changed.connect(_on_Navigation_Server_map_changed)

func open_init():
	_a_grid_step.set_x_value(50)
	_a_grid_step.set_y_value(50)
	_a_grid_offset.set_x_value(0)
	_a_grid_offset.set_x_max(49)
	_a_grid_offset.set_y_value(0)
	_a_grid_offset.set_y_max(49)

func open_load(p_data):
	var grid_step = p_data["Grid"]["Step"]
	var grid_offset = p_data["Grid"]["Offset"]
	_a_grid_step.set_x_value(grid_step.x)
	_a_grid_step.set_y_value(grid_step.y)
	_a_grid_offset.set_x_value(grid_offset.x)
	_a_grid_offset.set_x_max(grid_step.x - 1)
	_a_grid_offset.set_y_value(grid_offset.y)
	_a_grid_offset.set_y_max(grid_step.y - 1)

func update_point():
	var point_vec = _a_point.get_point_vec()
	var grid_step = _a_grid_step.get_value()
	var grid_start = _a_grid_offset.get_value()
	var point_pos = Global.grid_point_to_pos(point_vec, grid_step, grid_start)
	var point_scale = grid_step / 50.0
	_a_point.set_point_pos(point_pos)
	_a_point.set_point_scale(point_scale)

func handle_free_camera_pan(p_relative):
	var free_camera = _a_entity.get_free_camera_instance()
	free_camera.position -= p_relative

func handle_free_camera_zoom_in(p_factor):
	var free_camera = _a_entity.get_free_camera_instance()
	var camera_comp = free_camera.comph().get_comp("Camera")
	camera_comp.zoom += Vector2(p_factor, p_factor) * 0.1

func handle_free_camera_zoom_out(p_factor):
	var free_camera = _a_entity.get_free_camera_instance()
	var camera_comp = free_camera.comph().get_comp("Camera")
	camera_comp.zoom -= Vector2(p_factor, p_factor) * 0.1

func get_grid_length(p_grid_size):
	var grid_step = _a_grid_step.get_value()
	var grid_length = int(ceil(p_grid_size.y / grid_step.y))
	
	return grid_length

func get_global_mouse_pos():
	var preview_scene = _a_entity.get_preview_scene_instance()
	var global_pos = preview_scene.get_global_mouse_position()
	
	return global_pos

func _on_Navigation_Server_map_changed(_p_map_rid):
	nav_map_ready.emit()
