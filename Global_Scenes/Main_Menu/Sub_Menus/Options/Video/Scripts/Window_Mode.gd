extends "res://Global_Scenes/Debug/Scenes/Value_Select/Scripts/Value_Options.gd"

func _process(_p_delta):
	var window_mode = DisplayServer.window_get_mode()
	match window_mode:
		DisplayServer.WINDOW_MODE_FULLSCREEN:
			window_mode = "Fullscreen"
		DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			window_mode = "Exclusive_Fullscreen"
		_:
			window_mode = "Windowed"
	
	select(window_mode)
