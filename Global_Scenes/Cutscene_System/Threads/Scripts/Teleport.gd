extends "res://Global_Scenes/Cutscene_System/Threads/Scripts/Thread_Base.gd"

func _ready():
	super()
	if !_a_loads_data:
		_process_command()

func _process_command():
	var scene_manager_si = Global.get_singleton(self, "Scene_Manager")
	var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
	var teleportation = cutscene_system_si.get_option_value(_a_args["Teleportation"])
	var destination = cutscene_system_si.get_option_value(_a_args["Destination"])
	var dest = [teleportation, destination]
	scene_manager_si.change_scene_dest(dest)
	_emit_completed()
	queue_free()
	
	super()
