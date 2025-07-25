extends Node3D

class_name MapBase3D

@export var _e_BGM : AudioPlayback = null
@export var _e_BGS : Array[AudioPlayback] = []
@export var _e_can_jump : bool = true

var _a_Shared = preload("res://Scenes/Maps/Map_Base/Scripts/Shared.gd")

var _a_shared = null

func _ready():
	_a_shared = _a_Shared.new(self)
	_a_shared.set_BGM(_e_BGM)
	_a_shared.set_BGS(_e_BGS)
	
	_a_shared.ready()

func get_free_camera():
	return _a_shared.get_free_camera()

func get_free_audio():
	return _a_shared.get_free_audio()

func get_save_data():
	return _a_shared.get_save_data()

func load_data(p_map_data):
	_a_shared.load_data(p_map_data)

func load_data_init():
	_a_shared.load_data_init()

func get_can_jump():
	return _e_can_jump
