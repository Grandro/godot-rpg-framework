extends Node

@export var _e_free_cameras = {} # Match dim to scene

const _a_DIMENSIONS_PATH = "res://Global_Scenes/Debug/Teleport_Map/Dimensions/%s.gd"

var _a_Select_Point = preload("res://Global_Resources/Sprites/Debug/Cursors/Select_Point.png")

var _a_free_camera = null
var _a_dimensions = null

func _ready():
	set_physics_process(false)
	set_process_input(false)

func _physics_process(p_delta):
	var input_dir = Input.get_vector("Move_Left", "Move_Right", "Move_Up", "Move_Down")
	var relative = input_dir * p_delta
	_a_dimensions.handle_free_camera_pan(relative)

func _input(p_event):
	if p_event.is_action_pressed("Mouse_Left"):
		var global_pos = _a_dimensions.get_global_mouse_pos()
		if global_pos:
			var player = Global.get_player()
			player.set_global_position(global_pos)
			_close()
	
	if p_event.is_action_pressed("Mouse_Right"):
		_close()

func open():
	_a_free_camera = _instantiate_free_camera()
	_a_dimensions = _instantiate_dimensions()
	add_child(_a_free_camera)
	
	var player = Global.get_player()
	var global_pos = player.get_global_position()
	_a_free_camera.set_global_position(global_pos)
	_a_free_camera.comph().call_comp("Camera", "make_current_")
	Input.set_custom_mouse_cursor(_a_Select_Point, Input.CURSOR_ARROW, Vector2(12, 12))
	
	set_physics_process(true)
	set_process_input(true)
	get_tree().get_root().grab_focus()

func _close():
	_a_free_camera.queue_free()
	_a_dimensions.free()
	
	var camera = Global.get_curr_camera()
	var default_cursor = Global.get_default_cursor()
	camera.make_current_()
	Input.set_custom_mouse_cursor(default_cursor)
	
	set_physics_process(false)
	set_process_input(false)
	Debug.grab_window_focus()

func _instantiate_free_camera():
	var dim = Scene_Manager.get_curr_scene_dim()
	var scene = _e_free_cameras[dim]
	var instance = scene.instantiate()
	
	return instance

func _instantiate_dimensions():
	var dim = Scene_Manager.get_curr_scene_dim()
	var script = load(_a_DIMENSIONS_PATH % dim)
	var instance = script.new(self)
	
	return instance

func get_free_camera_instance():
	return _a_free_camera
