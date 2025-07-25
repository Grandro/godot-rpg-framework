extends HBoxContainer

signal started()
signal paused()
signal stopped()
signal seeked(p_pos)
signal path_changed(p_path)

const _a_SPRITES_PATH = "res://Global_Resources/Sprites/UI/%s.png"

enum _a_STATES {PLAY, PAUSE}

@export var _e_access: FileDialog.Access = FileDialog.ACCESS_FILESYSTEM
@export_dir var _e_dir_path = ""
@export var _e_filters: PackedStringArray = PackedStringArray(["*.wav", "*.ogg"])
@export_enum("Master", "BGM", "BGS", "SFX") var _e_bus = "BGM"

@onready var _a_Play = get_node("HBox/Play")
@onready var _a_Stop = get_node("HBox/Stop")
@onready var _a_Revert = get_node("Main/HBox/Revert")
@onready var _a_Revert_Anims = get_node("Main/HBox/Revert/Anims")
@onready var _a_Path_Text = get_node("Main/HBox/Path/Value")
@onready var _a_Progress = get_node("Main/Progress")
@onready var _a_Time_Text = get_node("Main/Options/Time")
@onready var _a_Select = get_node("Select")
@onready var _a_File = get_node("File")
@onready var _a_Audio = get_node("Audio")

var _a_path = ""
var _a_is_valid_stream = false
var _a_last_pos = 0.0
var _a_stream_length = 0.0

func _ready():
	_a_Play.pressed.connect(_on_Play_pressed)
	_a_Stop.pressed.connect(_on_Stop_pressed)
	_a_Revert.pressed.connect(_on_Revert_pressed)
	_a_Progress.gui_input.connect(_on_Progress_gui_input)
	_a_Select.pressed.connect(_on_Select_pressed)
	_a_File.file_selected.connect(_on_file_selected)
	_a_Audio.finished.connect(_on_Audio_finished)
	
	_a_Play.set_disabled(true)
	_a_Stop.set_disabled(true)
	set_process(false)
	
	_a_File.set_access(_e_access)
	_a_File.set_filters(_e_filters)
	_a_Audio.set_bus(_e_bus)

func _process(_p_delta):
	_a_last_pos = _a_Audio.get_playback_position()
	_update_time_text()
	_update_progress()

func update_trans():
	var curr_file = _a_File.get_current_file()
	if curr_file.is_empty():
		_a_Path_Text.set_text(tr("NONE"))
	_a_Select.set_text(tr("SELECT"))

func hide_file():
	_a_File.hide()

func stop_audio():
	_a_Audio.stop()

func _reset_audio():
	set_process(false)
	_a_Audio.stop()
	_a_last_pos = 0.0
	_set_play_pause_textures(_a_STATES.PLAY)
	_update_time_text()
	_update_progress()

func _update_time_text():
	var curr = _seconds_to_time(int(_a_last_pos))
	var length = _seconds_to_time(int(_a_stream_length))
	var text = "%s - %s" % [curr, length]
	_a_Time_Text.set_text(text)

func _update_progress():
	var percent = 0.0
	if _a_stream_length > 0.0:
		percent = _a_last_pos / _a_stream_length * 100
	_a_Progress.set_value(percent)

func _seconds_to_time(p_seconds):
	var minutes = int(p_seconds / 60)
	p_seconds -= minutes * 60
	
	var padded_minutes = str(minutes).pad_zeros(2)
	var padded_seconds = str(p_seconds).pad_zeros(2)
	var time = "%s:%s" % [padded_minutes, padded_seconds]
	
	return time

func _set_path_text(p_text):
	_a_Path_Text.set_text(p_text)

func _set_play_pause_textures(p_state):
	match p_state:
		_a_STATES.PLAY:
			var normal = load(_a_SPRITES_PATH % "Play_Normal")
			var disabled = load(_a_SPRITES_PATH % "Play_Disabled")
			_a_Play.set_texture_normal(normal)
			_a_Play.set_texture_disabled(disabled)
		_a_STATES.PAUSE:
			var normal = load(_a_SPRITES_PATH % "Pause_Normal")
			_a_Play.set_texture_normal(normal)
			_a_Play.set_texture_disabled(null)

func set_audio_stream(p_path):
	var stream = null
	var path_empty = p_path.is_empty()
	if path_empty:
		_a_File.set_current_file("")
		_set_path_text("NONE")
		_a_stream_length = 0.0
	elif p_path.begins_with("user://"):
		var extension = p_path.get_extension()
		match extension:
			"ogg": stream = Data_Parser.load_ogg_stream(p_path)
			"wav": stream = Data_Parser.load_wav_stream(p_path)
	else:
		stream = load(p_path)
	
	_a_Audio.set_stream(stream)
	_a_Play.set_disabled(path_empty)
	_a_Stop.set_disabled(path_empty)
	_a_path = p_path
	_a_is_valid_stream = !path_empty
	path_changed.emit(p_path)
	
	if path_empty:
		_reset_audio()
		return
	
	_a_File.set_current_path(p_path)
	_set_path_text(p_path)
	_a_stream_length = stream.get_length()
	_reset_audio()

func set_volume_db(p_volume_db):
	_a_Audio.set_volume_db(p_volume_db)

func set_pitch_scale(p_pitch_scale):
	_a_Audio.set_pitch_scale(p_pitch_scale)

func set_bus(p_bus):
	_a_Audio.set_bus(p_bus)
	_e_bus = p_bus

func set_disabled(p_disabled):
	var path_empty = _a_path.is_empty()
	_a_Play.set_disabled(p_disabled || !path_empty)
	_a_Stop.set_disabled(p_disabled || !path_empty)
	_a_Revert.set_disabled(p_disabled)
	_a_Select.set_disabled(p_disabled)

func get_audio_stream():
	return _a_Audio.get_stream()

func is_audio_playing():
	return _a_Audio.is_playing()

func get_audio_playback_position():
	return _a_Audio.get_playback_position()

func get_stream_path():
	var stream_path = ""
	var stream = _a_Audio.get_stream()
	if stream != null:
		stream_path = stream.get_path()
	
	return stream_path

func _on_Play_pressed():
	if _a_Audio.is_playing():
		_a_Audio.stop()
		set_process(false)
		_set_play_pause_textures(_a_STATES.PLAY)
		paused.emit()
	else:
		_a_Audio.play(_a_last_pos)
		set_process(true)
		_set_play_pause_textures(_a_STATES.PAUSE)
		started.emit()

func _on_Stop_pressed():
	_reset_audio()
	stopped.emit()

func _on_Revert_pressed():
	_a_Revert_Anims.play("Spin")
	if !_a_path.is_empty():
		set_audio_stream("")
		stopped.emit()

func _on_Progress_gui_input(p_event):
	if !_a_is_valid_stream:
		return
	
	if p_event.is_action("Mouse_Left"):
		if p_event.is_pressed():
			var x = p_event.get_position().x
			var width = _a_Progress.get_size().x
			var ratio = x / width
			_a_last_pos = ratio * _a_stream_length
			_a_Audio.seek(_a_last_pos)
			seeked.emit(_a_last_pos)
			
			if !_a_Audio.is_playing():
				_update_time_text()
				_update_progress()

func _on_Select_pressed():
	_a_File.set_current_dir(_e_dir_path)
	_a_File.popup_centered(Vector2(480, 660))

func _on_file_selected(p_path):
	var playing = _a_Audio.is_playing()
	set_audio_stream(p_path)
	if playing:
		stopped.emit()

func _on_Audio_finished():
	var pos = _a_Audio.get_playback_position()
	var round_pos = snapped(pos, 0.001)
	var round_length = snapped(_a_stream_length, 0.001)
	
	set_process(false)
	if round_pos == round_length:
		_reset_audio()
	
	stopped.emit()
