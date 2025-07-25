extends "res://Global_Scenes/Cutscene_System/Threads/Scripts/Thread_Base.gd"

func _ready():
	super()
	if !_a_loads_data:
		_process_command()

func skip():
	super()
	
	_emit_completed()
	queue_free()

func sub_process_completed(p_id):
	var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
	var id = cutscene_system_si.get_option_value(_a_args["ID"])
	if p_id == id && !_a_skip:
		_emit_completed()
		queue_free()
