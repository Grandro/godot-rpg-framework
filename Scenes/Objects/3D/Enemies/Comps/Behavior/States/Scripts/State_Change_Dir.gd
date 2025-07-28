extends "res://Scenes/Objects/3D/Enemies/Comps/Behavior/States/Scripts/State_Base.gd"

@export_enum("Rndm", "Look_At") var _e_type : String = "Rndm"

func process_start():
	var dir = ""
	match _e_type:
		"Rndm": dir = _get_dir_rndm()
		"Look_At": dir = _get_dir_look_at()
	
	_a_entity_comph.call_comp("Movement", "set_dir", [dir])
	_a_entity_comph.call_comp("Anims", "update_anim")
	
	processed.emit()

func _get_dir_rndm():
	var curr_dir = _a_entity_comph.call_comp("Movement", "get_dir")
	var dir = Global.get_rndm_dir(curr_dir)
	
	return dir

func _get_dir_look_at():
	var target = _a_behavior.get_target()
	var entity_pos = _a_entity.get_global_position()
	var target_pos = target.get_global_position()
	var dir = Global.get_dir_to_pos(entity_pos, target_pos)
	
	return dir
