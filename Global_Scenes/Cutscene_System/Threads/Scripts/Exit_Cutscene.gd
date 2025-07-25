extends "res://Global_Scenes/Cutscene_System/Threads/Scripts/Thread_Base.gd"

signal request_exit()

func _ready():
	super()
	if !_a_loads_data:
		_process_command()

func _process_command():
	request_exit.emit()
	
	super()
