extends "res://Global_Scenes/Debug/Scenes/Value_Select/Scripts/Value_Point_Base.gd"

func _init():
	_a_point_vec = Vector2.ZERO

func _update_value_text():
	super()
	if is_point_visible():
		_a_Value_Text.set_text("(%s, %s)" % [_a_point_vec.x, _a_point_vec.y])

func set_point_pos(p_pos):
	_a_point.set_position(p_pos)

func set_point_scale(p_scale):
	_a_point.set_scale(p_scale)
