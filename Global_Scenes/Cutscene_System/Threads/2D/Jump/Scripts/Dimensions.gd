extends "res://Scripts/Extension_Base.gd"

func tween_object_to_pos(p_tween, p_object, p_pos, p_duration):
	p_tween.tween_property(p_object, "global_position", p_pos, p_duration)
