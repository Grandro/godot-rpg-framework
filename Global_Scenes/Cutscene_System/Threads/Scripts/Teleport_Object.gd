extends "res://Global_Scenes/Cutscene_System/Threads/Scripts/Thread_Base.gd"

func _ready():
	super()
	if !_a_loads_data:
		_process_command()

func _process_command():
	var point_selected = _a_args["Point"]["Selected"]
	if point_selected:
		var global_si = Global.get_singleton(self, "Global")
		var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
		var object_key = cutscene_system_si.get_option_value(_a_args["Object"])
		var point = cutscene_system_si.get_option_value(_a_args["Point"])
		_a_object = global_si.get_object(object_key)
		_a_object.comph().call_comp("Cutscene", "increase_in_cutscene")
		
		var grid_step = _a_args["Grid"]["Step"]
		var grid_start = _a_args["Grid"]["Start"]
		var pos = Global.grid_point_to_pos(point, grid_step, grid_start)
		_a_object.set_global_position(pos)
	
	_emit_completed()
	queue_free()
	
	super()
