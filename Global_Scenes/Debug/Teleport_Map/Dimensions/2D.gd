extends "res://Scripts/Extension_Base.gd"

func handle_free_camera_pan(p_relative):
	var free_camera = _a_entity.get_free_camera_instance()
	free_camera.position -= p_relative

func get_global_mouse_pos():
	var curr_scene = Scene_Manager.get_curr_scene_instance()
	var global_pos = curr_scene.get_global_mouse_position()
	
	return global_pos
