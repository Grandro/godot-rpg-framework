extends "res://Scenes/Objects/3D/Enemies/Comps/Behavior/States/Scripts/State_Base.gd"

func process_start():
	var progress_si = Global.get_singleton(self, "Progress")
	var key = _a_entity_comph.call_comp("Reference", "get_key")
	progress_si.call_object(key, "start_respawn")
	
	processed.emit()
