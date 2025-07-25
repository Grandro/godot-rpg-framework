extends "res://Global_Scenes/Debug/Command_Edit/2D/Command_Preview/Scripts/Dimensions.gd"

var _a_Start_Sprite = preload("res://Global_Scenes/Debug/Sprites/Path/Start.png")
var _a_End_Sprite = preload("res://Global_Scenes/Debug/Sprites/Path/End.png")

func update_start_point(p_pos):
	var start_point = _a_entity.get_start_point_instance()
	var grid_offset = _a_grid_offset.get_value()
	var scale_ = _a_grid_step.get_value() / 50.0
	start_point.set_position(p_pos + grid_offset)
	start_point.set_scale(scale_)
	start_point.set_texture(_a_Start_Sprite)

func update_end_point(p_pos):
	var end_point = _a_entity.get_end_point_instance()
	var grid_offset = _a_grid_offset.get_value()
	var scale_ = _a_grid_step.get_value() / 50.0
	end_point.set_position(p_pos + grid_offset)
	end_point.set_scale(scale_)
	end_point.set_texture(_a_End_Sprite)

func is_value_vector(p_value):
	return typeof(p_value) == TYPE_VECTOR2
