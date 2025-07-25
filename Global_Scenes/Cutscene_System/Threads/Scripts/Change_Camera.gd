extends "res://Global_Scenes/Cutscene_System/Threads/Scripts/Thread_Base.gd"

func _ready():
	super()
	if !_a_loads_data:
		_process_command()

func _process_command():
	var global_si = Global.get_singleton(self, "Global")
	var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
	var object_key = cutscene_system_si.get_option_value(_a_args["Object"])
	_a_object = global_si.get_object(object_key)
	_a_object.comph().call_comp("Cutscene", "increase_in_cutscene")
	var camera = _a_object.comph().get_comp("Camera")
	global_si.set_curr_camera(camera)
	
	_emit_completed()
	queue_free()
	
	super()
