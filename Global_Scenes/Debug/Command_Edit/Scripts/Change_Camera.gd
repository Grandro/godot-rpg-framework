extends "res://Global_Scenes/Debug/Command_Edit/Scripts/Command_Preview_Object.gd"

func open(p_instance, p_data, p_res_data):
	super(p_instance, p_data, p_res_data)
	
	_selected_object_changed()
	
	# Check if selected camera was chosen by Move_Free_Camera
	var has_object_free_camera = false
	if p_res_data.has("Misc"):
		if p_res_data["Misc"].has("Free_Camera"):
			if p_res_data["Misc"]["Free_Camera"].has("Object"):
				has_object_free_camera = true
	
	if has_object_free_camera && p_data.is_empty():
		var key = p_res_data["Misc"]["Free_Camera"]["Object"]
		_a_Object.select(key)
		_selected_object_changed()
	
	_a_Window.show()
	show()

func _open_init(p_res_data):
	super(p_res_data)
	_a_Object.load_data_init()
	_select_default_object(p_res_data)
	_selected_object_changed()

func _open_load(p_data, p_res_data):
	super(p_data, p_res_data)
	_a_Object.load_data(p_data["Object"])
	_selected_object_changed()
