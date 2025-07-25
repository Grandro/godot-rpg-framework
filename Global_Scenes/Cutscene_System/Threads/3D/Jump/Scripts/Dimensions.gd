extends "res://Scripts/Extension_Base.gd"

func tween_object_to_pos(p_tween, p_object, p_pos, p_duration):
	p_tween.set_parallel(true)
	p_tween.tween_property(p_object, "global_position:x", p_pos.x, p_duration)
	p_tween.tween_property(p_object, "global_position:z", p_pos.z, p_duration)
