extends Node3D

signal audio_free_finished(p_file_name)

var _a_Shared = preload("res://Scenes/Object/Comps/Audio/Scripts/Shared.gd")

var _a_shared = null

func _ready():
	_a_shared = _a_Shared.new(self)
	_a_shared.audio_free_finished.connect(_on_Shared_audio_free_finished)
	_a_shared.ready()

func init(_p_entity):
	pass

func play(p_key, p_from = 0.0):
	_a_shared.play(p_key, p_from)

func stop(p_key):
	_a_shared.stop(p_key)

func set_stream(p_key, p_stream):
	_a_shared.set_stream(p_key, p_stream)

func set_volume(p_key, p_volume):
	_a_shared.set_volume(p_key, p_volume)

func set_pitch(p_key, p_pitch):
	_a_shared.set_pitch(p_key, p_pitch)

func set_bus(p_key, p_bus):
	_a_shared.set_bus(p_key, p_bus)

func set_max_distance(p_key, p_distance):
	_a_shared.set_max_distance(p_key, p_distance)

func set_attenuation(p_key, p_attenuation):
	_a_shared.set_attenuation(p_key, p_attenuation)

func get_save_data():
	return _a_shared.get_save_data()

func load_data(p_data):
	_a_shared.load_data(p_data)

func load_data_init():
	pass

func _on_Shared_audio_free_finished(p_file_name):
	audio_free_finished.emit(p_file_name)
