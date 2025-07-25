extends "res://Global_Scenes/Cutscene_System/Threads/Scripts/Thread_Base.gd"

func _ready():
	super()
	if !_a_loads_data:
		_process_command()

func _process_command():
	var global_si = Global.get_singleton(self, "Global")
	var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
	var args = _a_args["Args"]
	var object_key = cutscene_system_si.get_option_value(_a_args["Object"])
	var type = cutscene_system_si.get_option_value(_a_args["Type"])
	_a_object = global_si.get_object(object_key)
	_a_object.comph().call_comp("Cutscene", "increase_in_cutscene")
	
	var dir = _a_object.comph().call_comp("Movement", "get_dir")
	match type:
		"Fixed_Dir":
			dir = cutscene_system_si.get_option_value(args["Dir"])
		
		"Look_Degrees":
			var degrees = cutscene_system_si.get_option_value(args["Degrees"])
			dir = global_si.get_dir_rotated(dir, degrees)
		
		_:  # Look_At, Look_Away
			var start = _a_object.get_global_position()
			var look_type = cutscene_system_si.get_option_value(args["Type"])
			match look_type:
				"Object":
					var look_object_key = cutscene_system_si.get_option_value(args["Object"])
					var look_object = global_si.get_object(look_object_key)
					var end = look_object.get_global_position()
					if type == "Look_At":
						dir = global_si.get_dir_to_pos(start, end)
					elif type == "Look_Away":
						dir = global_si.get_opposite_dir(dir)
				
				"Point":
					var selected = args["Point"]["Selected"]
					if selected:
						var point = cutscene_system_si.get_option_value(args["Point"])
						var grid_step = _a_args["Grid"]["Step"]
						var grid_start = _a_args["Grid"]["Start"]
						var end = grid_start + (point * grid_step) + (grid_step / 2)
						if type == "Look_At":
							dir = global_si.get_dir_to_pos(start, end)
						elif type == "Look_Away":
							dir = global_si.get_opposite_dir(dir)
	
	_a_object.comph().call_comp("Movement", "set_dir", [dir])
	_a_object.comph().call_comp("Anims", "update_anim")
	
	_emit_completed()
	queue_free()
	
	super()
