extends "res://Global_Scenes/Debug/Command_Edit/Command_Preview_Base/Scripts/Dimensions.gd"

signal nav_map_ready()

var _a_preview_vp = null
var _a_point = null

func _init(p_entity):
	super(p_entity)
	_a_preview_vp = _a_entity.get_preview_vp_instance()
	_a_point = _a_entity.get_point_instance()
	
	NavigationServer3D.map_changed.connect(_on_Navigation_Server_map_changed)
	_a_grid_step.z_value_changed.connect(_on_Grid_Step_z_value_changed)
	_a_grid_offset.z_value_changed.connect(_on_Grid_Offset_value_changed)

func open_init():
	_a_grid_step.set_x_value(1)
	_a_grid_step.set_y_value(1)
	_a_grid_step.set_z_value(1)
	_a_grid_offset.set_x_value(0)
	_a_grid_offset.set_x_max(1)
	_a_grid_offset.set_y_value(0)
	_a_grid_offset.set_y_max(1)
	_a_grid_offset.set_z_value(0)
	_a_grid_offset.set_z_max(1)

func open_load(p_data):
	var grid_step = p_data["Grid"]["Step"]
	var grid_offset = p_data["Grid"]["Offset"]
	_a_grid_step.set_x_value(grid_step.x)
	_a_grid_step.set_y_value(grid_step.y)
	_a_grid_step.set_z_value(grid_step.z)
	_a_grid_offset.set_x_value(grid_offset.x)
	_a_grid_offset.set_x_max(grid_step.x)
	_a_grid_offset.set_y_value(grid_offset.y)
	_a_grid_offset.set_y_max(grid_step.y)
	_a_grid_offset.set_z_value(grid_offset.z)
	_a_grid_offset.set_z_max(grid_step.z)

func update_point():
	var draw_grid = _a_entity.get_draw_grid_instance()
	var point_vec = _a_point.get_point_vec()
	var grid_step = _a_grid_step.get_value()
	var grid_start = _a_grid_offset.get_value()
	var point_pos = Global.grid_point_to_pos(point_vec, grid_step, grid_start)
	var point_scale = _a_grid_step.get_value()
	draw_grid.set_y(point_pos.y)
	draw_grid.update_grid()
	_a_point.set_point_pos(point_pos)
	_a_point.set_point_scale(point_scale)

func handle_free_camera_pan(p_relative):
	var free_camera = _a_entity.get_free_camera_instance()
	free_camera.position.x -= p_relative.x * 0.03
	free_camera.position.z -= p_relative.y * 0.03

func handle_free_camera_zoom_in(p_factor):
	var free_camera = _a_entity.get_free_camera_instance()
	var camera_comp = free_camera.comph().get_comp("Camera")
	camera_comp.size -= 0.75 * p_factor

func handle_free_camera_zoom_out(p_factor):
	var free_camera = _a_entity.get_free_camera_instance()
	var camera_comp = free_camera.comph().get_comp("Camera")
	camera_comp.size += 0.75 * p_factor

func get_grid_length(p_grid_size):
	var grid_step = _a_grid_step.get_value()
	var grid_length = int(ceil(p_grid_size.y / grid_step.z))
	
	return grid_length

func get_global_mouse_pos():
	var mouse_pos = _a_preview_vp.get_mouse_position()
	var free_camera = _a_entity.get_free_camera_instance()
	var camera_comp = free_camera.comph().get_comp("Camera")
	var collision_mask = 1 # Terrain
	var global_pos = Global.get_screen_pos_3D(mouse_pos, camera_comp, collision_mask)
	
	return global_pos

func _on_Navigation_Server_map_changed(_p_map_rid):
	nav_map_ready.emit()

func _on_Grid_Step_z_value_changed(p_value):
	_a_grid_offset.set_z_max(p_value)
	_a_entity.update_grid()
