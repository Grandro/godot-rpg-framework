extends AudioStreamPlayer

var _a_Shared = preload("res://Scenes/Pausable_Audio/Scripts/Shared.gd")

var _a_shared = null

var _a_stream_paused = false

func _ready():
	_a_shared = _a_Shared.new(self)

func _notification(p_what):
	match p_what:
		NOTIFICATION_UNPAUSED: 
			stream_paused = _a_stream_paused

func set_stream_paused_(p_paused):
	stream_paused = p_paused
	_a_stream_paused = p_paused

func get_stream_paused_():
	return _a_stream_paused

func get_save_data():
	return _a_shared.get_save_data()

func load_data(p_data):
	_a_shared.load_data(p_data)

func load_data_init():
	pass
