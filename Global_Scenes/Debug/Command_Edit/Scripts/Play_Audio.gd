extends "res://Global_Scenes/Debug/Command_Edit/Scripts/Command_Preview_Object.gd"

@onready var _a_Audio_Type = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Audio_Type")
@onready var _a_Type = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Type")
@onready var _a_Audio = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Audio")
@onready var _a_Volume = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Volume")
@onready var _a_Pitch = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Pitch")
@onready var _a_Max_Distance = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Max_Distance")
@onready var _a_Wait_Finish = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Wait_Finish")

var _a_type = "" # Static/Object/Point

func _ready():
	_a_Point = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Point")
	super()
	
	_a_Audio_Type.selected.connect(_on_Audio_Type_selected)
	_a_Type.selected.connect(_on_Type_selected)
	_a_Audio.started.connect(_on_Audio_started)
	_a_Audio.paused.connect(_on_Audio_paused)
	_a_Audio.stopped.connect(_on_Audio_stopped)
	_a_Audio.seeked.connect(_on_Audio_seeked)
	_a_Volume.value_changed.connect(_on_Volume_value_changed)
	_a_Pitch.value_changed.connect(_on_Pitch_value_changed)
	_a_Max_Distance.value_changed.connect(_on_Max_Distance_value_changed)
	
	_a_Audio_Type.update_options()
	_a_Type.update_options()

func update_grid():
	super()
	if _a_type == "Point":
		if _a_Point.is_point_visible():
			_a_dimensions.update_point()

func open(p_instance, p_data, p_res_data):
	super(p_instance, p_data, p_res_data)
	
	var point = _a_Point.get_point_instance()
	_a_preview_scene.add_child(point)
	_selected_audio_type_changed()
	_selected_type_changed()
	
	_a_Window.show()
	show()

func close():
	_a_Audio.stop_audio()
	super()

func _open_init(p_res_data):
	super(p_res_data)
	_a_Audio_Type.load_data_init()
	_a_Audio_Type.select("BGM")
	_a_Type.load_data_init()
	_a_Type.select("Static")
	_a_Audio.load_data_init()
	_a_Volume.load_data_init()
	_a_Pitch.load_data_init()
	_a_Point.load_data_init()
	_a_Object.load_data_init()
	_select_default_object(p_res_data)
	_selected_object_changed()
	_a_Max_Distance.load_data_init()
	_a_Wait_Finish.load_data_init()

func _open_load(p_data, p_res_data):
	super(p_data, p_res_data)
	_a_Audio_Type.load_data(p_data["Audio_Type"])
	_a_Type.load_data(p_data["Type"])
	_a_Audio.load_data(p_data["Audio"])
	_a_Volume.load_data(p_data["Volume"])
	_a_Pitch.load_data(p_data["Pitch"])
	_a_Point.load_data(p_data["Point"])
	_a_Object.load_data(p_data["Object"])
	_selected_object_changed()
	_a_Max_Distance.load_data(p_data["Max_Distance"])
	_a_Wait_Finish.load_data(p_data["Wait_Finish"])

func _update_audio_playback():
	if _a_Audio.is_audio_playing():
		var bus = _a_Audio_Type.get_selected_key()
		var stream = _a_Audio.get_audio_stream()
		var from_pos = _a_Audio.get_audio_playback_position()
		var volume = _a_Volume.get_value()
		var pitch = _a_Pitch.get_value()
		
		var free_audio = _a_preview_scene.get_free_audio()
		match _a_type:
			"Static":
				free_audio.stop()
				_a_object.comph().call_comp("Audio", "stop", ["$Free"])
				
				_a_Audio.set_bus(bus)
				_a_Audio.set_volume_db(linear_to_db(volume))
				_a_Audio.set_pitch_scale(pitch)
			
			"Object":
				_a_Audio.set_volume_db(linear_to_db(0.0))
				free_audio.stop()
				
				var max_distance = _a_Max_Distance.get_value()
				_a_object.comph().call_comp("Audio", "set_bus", ["$Free", bus])
				_a_object.comph().call_comp("Audio", "set_stream", ["$Free", stream])
				_a_object.comph().call_comp("Audio", "set_volume", ["$Free", linear_to_db(volume)])
				_a_object.comph().call_comp("Audio", "set_pitch", ["$Free", pitch])
				_a_object.comph().call_comp("Audio", "set_max_distance", ["$Free", max_distance])
				_a_object.comph().call_comp("Audio", "play", ["$Free", from_pos])
			
			"Point":
				_a_Audio.set_volume_db(linear_to_db(0.0))
				_a_object.comph().call_comp("Audio", "stop", ["$Free"])
				
				if !_a_Point.is_point_visible():
					free_audio.stop()
					return
				
				var point = _a_Point.get_point_vec()
				var pos = _grid_point_to_pos(point)
				var max_distance = _a_Max_Distance.get_value()
				free_audio.set_position(pos)
				free_audio.set_bus(bus)
				free_audio.set_stream(stream)
				free_audio.set_volume_db(linear_to_db(volume))
				free_audio.set_pitch_scale(pitch)
				free_audio.set_max_distance(max_distance)
				free_audio.play(from_pos)
	else:
		match _a_type:
			"Object":
				_a_object.comph().call_comp("Audio", "stop", ["$Free"])
			
			"Point":
				var free_audio = _a_preview_scene.get_free_audio()
				free_audio.stop()

func _reset_object():
	if _a_object != null:
		_a_object.comph().call_comp("Audio", "stop", ["$Free"])
		#_a_object.set_material(null)

func _selected_audio_type_changed():
	var bus = _a_Audio_Type.get_selected_key()
	_a_Audio.set_bus(bus)
	
	_update_audio_playback()

func _selected_type_changed():
	_a_type = _a_Type.get_selected_key()
	match _a_type:
		"Static":
			_a_Object.hide()
			_a_Max_Distance.hide()
			_a_Point.hide()
			_reset_object()
			_a_Point.set_point_visible(false)
			
			_update_audio_playback()
		
		"Object":
			_a_Object.show()
			_a_Max_Distance.show()
			_a_Point.hide()
			_selected_object_changed()
			_a_Point.set_point_visible(false)
		
		"Point":
			_a_Object.hide()
			_a_Max_Distance.show()
			_a_Point.show()
			_reset_object()
			_a_Point.set_point_visible(true)
			
			_update_audio_playback()

func _selected_object_changed():
	_reset_object()
	
	var selected = _a_Object.get_selected_value()
	#selected.set_material(_e_outline_shader)
	var selected_pos = selected.get_position()
	_a_free_camera.set_position(selected_pos)
	_a_free_camera.comph().call_comp("Camera", "make_current_")
	
	_a_object = selected
	_update_audio_playback()

func _get_save_data():
	var data = super()
	data["Audio_Type"] = _a_Audio_Type.get_save_data()
	data["Type"] = _a_Type.get_save_data()
	data["Audio"] = _a_Audio.get_save_data()
	data["Volume"] = _a_Volume.get_save_data()
	data["Pitch"] = _a_Pitch.get_save_data()
	data["Point"] = _a_Point.get_save_data()
	data["Max_Distance"] = _a_Max_Distance.get_save_data()
	data["Wait_Finish"] = _a_Wait_Finish.get_save_data()
	
	return data

func _on_Preview_gui_input(p_event):
	super(p_event)
	
	if p_event.is_action_pressed("Mouse_Left"):
		if _a_type == "Point":
			var global_pos = _a_dimensions.get_global_mouse_pos()
			if global_pos:
				var point = _pos_to_grid_point(global_pos)
				var curr_point = _a_Point.get_point_vec()
				if curr_point == point && _a_Point.is_point_visible():
					_a_Point.set_point_visible(false)
				else:
					_a_Point.set_point_vec(point)
					_a_dimensions.update_point()
					_a_Point.set_point_visible(true)
				
				_update_audio_playback.call_deferred()

func _on_Audio_Type_selected():
	_selected_audio_type_changed()

func _on_Type_selected():
	_selected_type_changed()

func _on_Audio_started():
	_update_audio_playback()

func _on_Audio_paused():
	_update_audio_playback()

func _on_Audio_stopped():
	_update_audio_playback()

func _on_Audio_seeked(_p_pos):
	_update_audio_playback()

func _on_Volume_value_changed(_p_value):
	_update_audio_playback()

func _on_Pitch_value_changed(_p_value):
	_update_audio_playback()

func _on_Max_Distance_value_changed(_p_value):
	_update_audio_playback()

func _on_Attenuation_value_changed(_p_value):
	_update_audio_playback()
