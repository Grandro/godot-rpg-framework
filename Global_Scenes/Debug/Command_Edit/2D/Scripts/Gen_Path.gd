extends "res://Global_Scenes/Debug/Command_Edit/Scripts/Gen_Path_Base.gd"

func _instantiate_sprite(p_point, p_sprite_name, p_main):
	var instance = super(p_point, p_sprite_name, p_main)
	var half_offset = _a_step / 2
	var pos = _a_start + (p_point * _a_step) + half_offset
	var scale_ = _a_step / 50.0
	instance.set_position(pos)
	instance.set_scale(scale_)

func _adjust_approach(p_approach, p_dir):
	match p_dir:
		"Right": p_approach.x -= 1
		"Left": p_approach.x += 1
		"Down": p_approach.y -= 1
		"Up": p_approach.y += 1
	
	return p_approach

func _get_world():
	var vp = get_viewport()
	var world_2d = vp.find_world_2d()
	
	return world_2d

func _get_nav_path(p_from, p_to, p_map_rid):
	var from_pos = Global.grid_point_to_pos(p_from, _a_step, _a_start)
	var to_pos = Global.grid_point_to_pos(p_to, _a_step, _a_start)
	var nav_path = NavigationServer2D.map_get_path(p_map_rid, from_pos, to_pos, true)
	
	return nav_path

func _get_next_dir(p_approach):
	var dir = ""
	if abs(p_approach.x) > abs(p_approach.y):
		if p_approach.x > 0:
			dir = "Right"
		else:
			dir = "Left"
	else:
		if p_approach.y > 0:
			dir = "Down"
		else:
			dir = "Up"
	
	return dir

func _is_approach_at_target(p_approach):
	return p_approach == Vector2.ZERO
