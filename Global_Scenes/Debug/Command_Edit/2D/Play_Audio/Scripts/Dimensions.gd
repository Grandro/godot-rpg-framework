extends "res://Global_Scenes/Debug/Command_Edit/2D/Command_Preview/Scripts/Dimensions.gd"

func update_point():
	super()
	
	var preview_scene = _a_entity.get_preview_scene_instance()
	var point_vec = _a_point.get_point_vec()
	var grid_step = _a_grid_step.get_value()
	var grid_start = _a_grid_offset.get_value()
	var point_pos = Global.grid_point_to_pos(point_vec, grid_step, grid_start)
	var free_audio = preview_scene.get_free_audio()
	free_audio.set_position(point_pos)
