extends "res://Scenes/Object/Comps/Interactions/Scripts/Shared.gd"

func interaction(p_area):
	var dest = _a_entity_entity.get_destination()
	if dest.is_empty():
		super(p_area)
		return
	
	var scene_manager_si = Global.get_singleton(_a_entity, "Scene_Manager")
	scene_manager_si.change_scene_dest(dest)
	
	p_area.increase_interaction_count()
	interacted.emit()
