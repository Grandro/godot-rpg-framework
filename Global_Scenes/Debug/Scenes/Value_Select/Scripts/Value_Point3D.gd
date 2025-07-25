extends "res://Global_Scenes/Debug/Scenes/Value_Select/Scripts/Value_Point_Base.gd"

func _init():
	_a_point_vec = Vector3.ZERO

func _update_value_text():
	super()
	if is_point_visible():
		_a_Value_Text.set_text("(%s, %s, %s)" % [_a_point_vec.x, _a_point_vec.y, _a_point_vec.z])

func set_point_pos(p_pos):
	_a_point.set_position(Vector3(p_pos.x, p_pos.y + 0.01, p_pos.z))

func set_point_scale(p_scale):
	_a_point.set_scale(Vector3(p_scale.x, p_scale.z, 1.0))
