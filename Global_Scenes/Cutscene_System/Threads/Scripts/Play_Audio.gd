extends "res://Global_Scenes/Cutscene_System/Threads/Scripts/Thread_Base.gd"

var _a_audio_type = ""
var _a_type = ""
var _a_stream_path = ""
var _a_volume = 0.0
var _a_pitch = 0.0
var _a_wait_finish = false
var _a_max_distance = 0.0
var _a_object_key = ""
var _a_point_selected = false
var _a_point_pos = null # Vector

func _ready():
	super()
	if !_a_loads_data:
		var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
		_a_object_key = cutscene_system_si.get_option_value(_a_args["Object"])
		_a_audio_type = cutscene_system_si.get_option_value(_a_args["Audio_Type"])
		_a_type = cutscene_system_si.get_option_value(_a_args["Type"])
		_a_stream_path = cutscene_system_si.get_option_value(_a_args["Audio"])
		_a_volume = cutscene_system_si.get_option_value(_a_args["Volume"])
		_a_pitch = cutscene_system_si.get_option_value(_a_args["Pitch"])
		_a_wait_finish = cutscene_system_si.get_option_value(_a_args["Wait_Finish"])
		_a_max_distance = cutscene_system_si.get_option_value(_a_args["Max_Distance"])
		_a_point_selected = _a_args["Point"]["Selected"]
		
		var point = cutscene_system_si.get_option_value(_a_args["Point"])
		var grid_step = _a_args["Grid"]["Step"]
		var grid_start = _a_args["Grid"]["Start"]
		_a_point_pos = Global.grid_point_to_pos(point, grid_step, grid_start)
		_process_command()

func skip():
	super()
	
	_emit_completed()
	queue_free()

func _process_command():
	if _a_stream_path.is_empty():
		if !_a_skip:
			_emit_completed()
			queue_free()
		return
	
	var stream = load(_a_stream_path)
	match _a_type:
		"Static": _process_command_static(stream)
		"Object": _process_command_object(stream)
		"Point": _process_command_point(stream)
	
	if !_a_wait_finish && !_a_skip:
		_emit_completed()
		queue_free()
	
	super()

func _process_command_static(p_stream):
	var audio_manager_si = Global.get_singleton(self, "Audio_Manager")
	match _a_audio_type:
		"BGM":
			if _a_wait_finish:
				audio_manager_si.bgm_finished.connect(_on_Audio_Manager_bgm_finished)
			audio_manager_si.play_bgm(p_stream, _a_volume, _a_pitch)
		"SFX":
			if _a_wait_finish:
				audio_manager_si.sfx_finished.connect(_on_Audio_Manager_sfx_finished)
			audio_manager_si.play_sfx(p_stream, _a_volume, _a_pitch)
		"BGS":
			if _a_wait_finish:
				audio_manager_si.bgs_finished.connect(_on_Audio_Manager_bgs_finished)
			audio_manager_si.play_bgs(p_stream, _a_volume, _a_pitch)

func _process_command_object(p_stream):
	var global_si = Global.get_singleton(self, "Global")
	_a_object = global_si.get_object(_a_object_key)
	_a_object.comph().call_comp("Cutscene", "increase_in_cutscene")
	if _a_wait_finish:
		var audio_comp = _a_object.comph().get_comp("Audio")
		audio_comp.audio_free_finished.connect(_on_Object_audio_free_finished.bind(_a_audio_type))
	_a_object.comph().call_comp("Audio", "set_bus", ["$Free", _a_audio_type])
	_a_object.comph().call_comp("Audio", "set_max_distance", ["$Free", _a_max_distance])
	_a_object.comph().call_comp("Audio", "set_stream", ["$Free", p_stream])
	_a_object.comph().call_comp("Audio", "set_volume", ["$Free", linear_to_db(_a_volume)])
	_a_object.comph().call_comp("Audio", "set_pitch", ["$Free", _a_pitch])
	_a_object.comph().call_comp("Audio", "play", ["$Free"])

func _process_command_point(p_stream):
	if !_a_point_selected:
		if !_a_skip:
			_emit_completed()
			queue_free()
		return
	
	var free_audio = _a_curr_scene.get_free_audio()
	if _a_wait_finish:
		free_audio.finished.connect(_on_Free_Audio_finished.bind(free_audio))
	free_audio.set_global_position(_a_point_pos)
	free_audio.set_bus(_a_audio_type)
	free_audio.set_max_distance(_a_max_distance)
	free_audio.set_stream(p_stream)
	free_audio.set_volume_db(linear_to_db(_a_volume))
	free_audio.set_pitch_scale(_a_pitch)
	free_audio.play()

func get_save_data():
	var data = super()
	var args = data["Args"]
	args["Stream_Path"] = _a_stream_path
	args["Audio_Type"] = _a_audio_type
	
	return data

func load_data(p_data):
	super(p_data)
	
	var args = p_data["Args"]
	_a_stream_path = args["Stream_Path"]
	_a_audio_type = args["Audio_Type"]
	
	# Don't process command!
	# This is handled in Audio_Manager/Object/Free_Audio

func _on_Audio_Manager_bgm_finished(p_file_name):
	var file_name = _a_stream_path.get_file()
	if file_name == p_file_name && !_a_skip:
		_emit_completed()
		queue_free()

func _on_Audio_Manager_sfx_finished(p_file_name):
	var file_name = _a_stream_path.get_file()
	if file_name == p_file_name && !_a_skip:
		_emit_completed()
		queue_free()

func _on_Audio_Manager_bgs_finished(p_file_name):
	var file_name = _a_stream_path.get_file()
	if file_name == p_file_name && !_a_skip:
		_emit_completed()
		queue_free()

func _on_Object_audio_free_finished(p_file_name, p_audio_type):
	if _a_audio_type == p_audio_type:
		var file_name = _a_stream_path.get_file()
		if file_name == p_file_name && !_a_skip:
			_emit_completed()
			queue_free()

func _on_Free_Audio_finished(p_free_audio):
	var audio_type = p_free_audio.get_bus()
	var free_audio_stream = p_free_audio.get_stream()
	var free_audio_file_path = free_audio_stream.get_path()
	var free_audio_file_name = free_audio_file_path.get_file()
	if _a_audio_type == audio_type:
		var file_name = _a_stream_path.get_file()
		if file_name == free_audio_file_name && !_a_skip:
			_emit_completed()
			queue_free()
