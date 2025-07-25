extends Resource
class_name AudioPlayback

@export var _e_stream : AudioStream = null
@export var _e_volume : float = 1.0
@export var _e_pitch : float = 1.0
@export var _e_from : float = 0.0

func get_stream():
	return _e_stream

func get_volume():
	return _e_volume

func get_pitch():
	return _e_pitch

func get_from():
	return _e_from
