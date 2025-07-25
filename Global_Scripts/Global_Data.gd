extends Node

signal keyboard_layout_changed(p_keyboard_layout)

const _a_SAVE_PATH = "user://Saves/Global.save"

var _a_data = {} # Globally Saved Data

func _ready():
	_load_global_data()

func apply_options_audio_volume_master(p_volume):
	var db_volume = linear_to_db(p_volume)
	var bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_idx, db_volume)

func apply_options_audio_volume_BGM(p_volume):
	var db_volume = linear_to_db(p_volume)
	var bus_idx = AudioServer.get_bus_index("BGM")
	AudioServer.set_bus_volume_db(bus_idx, db_volume)

func apply_options_audio_volume_BGS(p_volume):
	var db_volume = linear_to_db(p_volume)
	var bus_idx = AudioServer.get_bus_index("BGS")
	AudioServer.set_bus_volume_db(bus_idx, db_volume)

func apply_options_audio_volume_SFX(p_volume):
	var db_volume = linear_to_db(p_volume)
	var bus_idx = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_idx, db_volume)

func apply_options_video_vsync_mode(p_vsync_mode):
	match p_vsync_mode:
		"Disabled": DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		"Enabled": DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		"Adaptive": DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
		"Mailbox": DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_MAILBOX)

func apply_options_video_window_size(p_window_size):
	match p_window_size:
		"240x135": DisplayServer.window_set_size(Vector2i(240, 135))
		"480x270": DisplayServer.window_set_size(Vector2i(480, 270))
		"720x405": DisplayServer.window_set_size(Vector2i(720, 405))
		"960x540": DisplayServer.window_set_size(Vector2i(960, 540))
		"1280x720": DisplayServer.window_set_size(Vector2i(1280, 720))
		"1600x900": DisplayServer.window_set_size(Vector2i(1600, 900))
		"1920x1080": DisplayServer.window_set_size(Vector2i(1920, 1080))
		"2560x1440": DisplayServer.window_set_size(Vector2i(2560, 1440))
		"3840x2160": DisplayServer.window_set_size(Vector2i(3840, 2160))

func apply_options_video_window_mode(p_window_mode):
	match p_window_mode:
		"Windowed": 
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		"Fullscreen": 
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		"Exclusive_Fullscreen": 
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

func apply_options_controls_keyboard_layout(p_keyboard_layout):
	keyboard_layout_changed.emit(p_keyboard_layout)

func apply_locale(p_locale):
	TranslationServer.set_locale(p_locale)

func _apply():
	_apply_options(_a_data["Options"])
	apply_locale(_a_data["Locale"])

func _apply_options(p_data):
	_apply_options_audio(p_data["Audio"])
	_apply_options_video(p_data["Video"])

func _apply_options_audio(p_data):
	# Volume
	_apply_options_audio_volume(p_data["Volume"])

func _apply_options_audio_volume(p_data):
	apply_options_audio_volume_master(p_data["Master"]["Value"])
	apply_options_audio_volume_BGM(p_data["BGM"]["Value"])
	apply_options_audio_volume_BGS(p_data["BGS"]["Value"])
	apply_options_audio_volume_SFX(p_data["SFX"]["Value"])

func _apply_options_video(p_data):
	apply_options_video_vsync_mode(p_data["VSync_Mode"]["Value"])
	apply_options_video_window_size(p_data["Window_Size"]["Value"])
	apply_options_video_window_mode(p_data["Window_Mode"]["Value"])

func _validate():
	var save_file_idx = _a_data["Save_File_Idx"]
	if save_file_idx != -1:
		var save_path = Global.get_save_path() % str(save_file_idx)
		if !FileAccess.file_exists(save_path):
			_a_data["Save_File_Idx"] = -1
	
	var version = _a_data["Version"]
	var curr_version = Global.get_version()
	while version != curr_version:
		match version:
			"0.0.6":
				_validate_006_to_007()
				version = "0.0.7"
	
	_a_data["Version"] = curr_version

func _validate_006_to_007():
	pass

func _get_init_data():
	var data = {}
	data["Options"] = _get_init_data_options()
	data["Locale"] = _get_init_data_locale()
	data["Version"] = Global.get_version()
	data["Save_File_Idx"] = -1
	
	return data

func _get_init_data_options():
	var data = {}
	data["Audio"] = _get_init_data_options_audio()
	data["Video"] = _get_init_data_options_video()
	data["Gameplay"] = _get_init_data_options_gameplay()
	data["Controls"] = _get_init_data_options_controls()
	
	return data

func _get_init_data_options_audio():
	var data = {}
	data["Volume"] = _get_init_data_options_audio_volume()
	
	return data

func _get_init_data_options_audio_volume():
	var data = {}
	data["Master"] = {}
	data["Master"]["Value"] = 0.5
	data["BGM"] = {}
	data["BGM"]["Value"] = 1.0
	data["BGS"] = {}
	data["BGS"]["Value"] = 1.0
	data["SFX"] = {}
	data["SFX"]["Value"] = 1.0
	
	return data

func _get_init_data_options_video():
	var data = {}
	data["VSync_Mode"] = {}
	data["VSync_Mode"]["Value"] = "Disabled"
	data["Window_Size"] = {}
	data["Window_Size"]["Value"] = "1280x720"
	data["Window_Mode"] = {}
	data["Window_Mode"]["Value"] = "Windowed"
	
	return data

func _get_init_data_options_gameplay():
	var data = {}
	
	return data

func _get_init_data_options_controls():
	var data = {}
	data["Keyboard_Layout"] = {}
	
	var keyboard_layout = "QWERTY"
	var locale = TranslationServer.get_locale()
	if "de" in locale:
		keyboard_layout = "QWERTZ"
	data["Keyboard_Layout"]["Value"] = keyboard_layout
	
	return data

func _get_init_data_locale():
	var loaded_locales = TranslationServer.get_loaded_locales()
	var locale = OS.get_locale_language()
	if !loaded_locales.has(locale):
		locale = "en"
	
	return locale

func set_entry_data(p_key, p_data):
	_a_data[p_key] = p_data

func get_entry_data(p_key):
	return _a_data[p_key]

func set_options_audio_volume_master(p_volume):
	_a_data["Options"]["Audio"]["Volume"]["Master"]["Value"] = p_volume
	apply_options_audio_volume_master(p_volume)

func set_options_audio_volume_BGM(p_volume):
	_a_data["Options"]["Audio"]["Volume"]["BGM"]["Value"] = p_volume
	apply_options_audio_volume_BGM(p_volume)

func set_options_audio_volume_BGS(p_volume):
	_a_data["Options"]["Audio"]["Volume"]["BGS"]["Value"] = p_volume
	apply_options_audio_volume_BGS(p_volume)

func set_options_audio_volume_SFX(p_volume):
	_a_data["Options"]["Audio"]["Volume"]["SFX"]["Value"] = p_volume
	apply_options_audio_volume_SFX(p_volume)

func set_options_video_vsync_mode(p_vsync_mode):
	_a_data["Options"]["Video"]["VSync_Mode"]["Value"] = p_vsync_mode
	apply_options_video_vsync_mode(p_vsync_mode)

func set_options_video_window_size(p_window_size):
	_a_data["Options"]["Video"]["Window_Size"]["Value"] = p_window_size
	apply_options_video_window_size(p_window_size)

func set_options_video_window_mode(p_window_mode):
	_a_data["Options"]["Video"]["Window_Mode"]["Value"] = p_window_mode
	apply_options_video_window_mode(p_window_mode)

func set_options_controls_keyboard_layout(p_keyboard_layout):
	_a_data["Options"]["Controls"]["Keyboard_Layout"]["Value"] = p_keyboard_layout
	apply_options_controls_keyboard_layout(p_keyboard_layout)

func get_options_controls_keyboard_layout():
	return _a_data["Options"]["Controls"]["Keyboard_Layout"]["Value"]

func set_locale(p_locale):
	_a_data["Locale"] = p_locale
	apply_locale(p_locale)

func get_locale():
	return _a_data["Locale"]

func set_save_file_idx(p_save_file_idx):
	_a_data["Save_File_Idx"] = p_save_file_idx

func get_save_file_idx():
	return _a_data["Save_File_Idx"]

func save_data():
	Data_Parser.write_var_data(_a_SAVE_PATH, _a_data)

func _load_global_data():
	if FileAccess.file_exists(_a_SAVE_PATH):
		_a_data = Data_Parser.load_var_data(_a_SAVE_PATH)
		_validate()
	else:
		_a_data = _get_init_data()
	
	_apply()
