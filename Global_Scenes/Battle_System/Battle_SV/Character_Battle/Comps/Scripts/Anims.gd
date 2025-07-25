extends "res://Scenes/Object/Comps/Scripts/Anims.gd"

func update_anim():
	if !_a_entity_comph.has_comp("States"):
		return
	if !_a_entity_comph.has_comp("Movement"):
		return
	
	var state_tmp = _a_entity_comph.call_comp("States", "get_state_tmp")
	var dir = _a_entity_comph.call_comp("Movement", "get_dir")
	var anim_name = "SV/%s_%s" % [state_tmp, dir]
	play_anim(anim_name)
