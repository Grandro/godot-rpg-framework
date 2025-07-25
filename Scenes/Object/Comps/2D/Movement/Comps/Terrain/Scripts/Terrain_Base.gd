extends Node2D

@export var _e_shared : GDScript = preload("res://Scenes/Object/Comps/Movement/Comps/Terrain/Scripts/Shared_Base.gd")
@export var _e_audio_base_path = "" # (String, DIR)
@export var _e_veil_base_path = "" # (String, DIR)

var _a_shared = null

func _ready():
	_a_shared = _e_shared.new(self)
	_a_shared.set_audio_base_path(_e_audio_base_path)
	_a_shared.set_veil_base_path(_e_veil_base_path)
	_a_shared.ready()

func init(p_entity):
	_a_shared.init(p_entity)

func play_audio(p_key):
	_a_shared.play_audio(p_key)

func reset_velocity():
	_a_shared.reset_velocity()

func adjust_velocity_post(p_velocity):
	return _a_shared.adjust_velocity_post(p_velocity)

func get_velocity_():
	return _a_shared.get_velocity()

func get_speed():
	return _a_shared.get_speed()

func get_save_data():
	return {}

func load_data(_p_data):
	pass

func load_data_init():
	pass
