extends Area2D

var _a_Shared = preload("res://Scenes/Object/Comps/Movement/Comps/Terrain/Area/Scripts/Shared.gd")

var _a_shared = null

func _ready():
	_a_shared = _a_Shared.new(self)
	_a_shared.ready()

func play_audio():
	_a_shared.play_audio()

func set_audio_base_path(p_audio_base_path):
	_a_shared.set_audio_base_path(p_audio_base_path)

func set_veil_base_path(p_veil_base_path):
	_a_shared.set_veil_base_path(p_veil_base_path)

func get_areas():
	return _a_shared.get_areas()
