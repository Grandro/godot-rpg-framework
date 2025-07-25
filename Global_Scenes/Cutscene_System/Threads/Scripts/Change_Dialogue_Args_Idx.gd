extends "res://Global_Scenes/Cutscene_System/Threads/Scripts/Thread_Base.gd"

func _ready():
	super()
	if !_a_loads_data:
		_process_command()

func _process_command():
	var global_si = Global.get_singleton(self, "Global")
	var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
	var object_key = cutscene_system_si.get_option_value(_a_args["Object"])
	var type = cutscene_system_si.get_option_value(_a_args["Type"])
	var idx = cutscene_system_si.get_option_value(_a_args["Idx"])
	var value = cutscene_system_si.get_option_value(_a_args["Value"])
	_a_object = global_si.get_object(object_key)
	_a_object.comph().call_comp("Cutscene", "increase_in_cutscene")
	
	var interactions_comp = _a_object.comph().get_comp("Interactions")
	match type:
		"Set": interactions_comp.set_interaction_dialogue_args_idx(idx, value)
		"Increase": interactions_comp.increase_interaction_dialogue_args_idx(idx, value)
		"Decrease": interactions_comp.decrease_interaction_dialogue_args_idx(idx, value)
	
	_emit_completed()
	queue_free()
	
	super()
