extends "res://Scripts/Extension_Base.gd"

signal audio_free_finished(p_file_name)

var _a_Audio_Free = null

func ready():
	_a_Audio_Free = _a_entity.get_node("$Free")
	
	_a_Audio_Free.finished.connect(_on_Audio_Free_finished)

func play(p_key, p_from):
	var instance = _a_entity.get_node(p_key)
	instance.play(p_from)

func stop(p_key):
	var instance = _a_entity.get_node(p_key)
	instance.stop()

func set_stream(p_key, p_stream):
	var instance = _a_entity.get_node(p_key)
	instance.set_stream(p_stream)

func set_volume(p_key, p_volume):
	var instance = _a_entity.get_node(p_key)
	instance.set_volume_db(p_volume)

func set_pitch(p_key, p_pitch):
	var instance = _a_entity.get_node(p_key)
	instance.set_pitch_scale(p_pitch)

func set_bus(p_key, p_bus):
	var instance = _a_entity.get_node(p_key)
	instance.set_bus(p_bus)

func set_max_distance(p_key, p_distance):
	var instance = _a_entity.get_node(p_key)
	instance.set_max_distance(p_distance)

func set_attenuation(p_key, p_attenuation):
	var instance = _a_entity.get_node(p_key)
	instance.set_attenuation(p_attenuation)

func get_save_data():
	var data = {}
	for child in _a_entity.get_children():
		var key = child.get_name()
		data[key] = child.get_save_data()
	
	return data

func load_data(p_data):
	for key in p_data:
		var instance = _a_entity.get_node(NodePath(key))
		instance.load_data(p_data[key])

func _on_Audio_Free_finished():
	var stream = _a_Audio_Free.get_stream()
	var file_path = stream.get_path()
	var file_name = file_path.get_file()
	audio_free_finished.emit(file_name)
