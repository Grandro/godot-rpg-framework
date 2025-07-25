extends "res://Scripts/Extension_Base.gd"

func handle_free_camera_pan(p_relative):
	var free_camera = _a_entity.get_free_camera_instance()
	free_camera.position.x -= p_relative.x * 0.03
	free_camera.position.z -= p_relative.y * 0.03

func get_global_mouse_pos():
	var mouse_pos = _a_entity.get_viewport().get_mouse_position()
	var free_camera = _a_entity.get_free_camera_instance()
	var camera_comp = free_camera.comph().get_comp("Camera")
	var collision_mask = 1 # Terrain
	var global_pos = Global.get_screen_pos_3D(mouse_pos, camera_comp, collision_mask)
	
	return global_pos
