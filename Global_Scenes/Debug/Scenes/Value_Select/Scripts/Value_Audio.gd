extends "res://Global_Scenes/Debug/Scenes/Value_Select/Scripts/Value_Select.gd"

signal started()
signal paused()
signal stopped()
signal seeked(p_pos)

@onready var _a_Value = get_node("Value")

func _ready():
	super()
	_a_Value.started.connect(_on_Value_started)
	_a_Value.paused.connect(_on_Value_paused)
	_a_Value.stopped.connect(_on_Value_stopped)
	_a_Value.seeked.connect(_on_Value_seeked)

func stop_audio():
	_a_Value.stop_audio()

func set_bus(p_bus):
	_a_Value.set_bus(p_bus)

func set_volume_db(p_volume_db):
	_a_Value.set_volume_db(p_volume_db)

func set_pitch_scale(p_pitch_scale):
	_a_Value.set_pitch_scale(p_pitch_scale)

func is_audio_playing():
	return _a_Value.is_audio_playing()

func get_audio_stream():
	return _a_Value.get_audio_stream()

func get_audio_playback_position():
	return _a_Value.get_audio_playback_position()

func get_save_data():
	var data = super()
	data["Value"] = _a_Value.get_stream_path()
	
	return data

func load_data(p_data):
	super(p_data)
	_a_Value.set_audio_stream(p_data["Value"])

func load_data_init():
	_a_Value.set_audio_stream("")

func _on_Var_Select_active_toggled(p_toggled):
	_a_Value.set_disabled(p_toggled)

func _on_Value_started():
	started.emit()

func _on_Value_paused():
	paused.emit()

func _on_Value_stopped():
	stopped.emit()

func _on_Value_seeked(p_pos):
	seeked.emit(p_pos)
