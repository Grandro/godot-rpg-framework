extends "res://Scripts/Extension_Base.gd"

func ready():
	var avoidance_enabled = _a_entity.get_avoidance_enabled()
	if !avoidance_enabled:
		_a_entity.queue_free()
