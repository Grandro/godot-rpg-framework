extends CanvasLayer

signal completed()
signal choice_selected(p_value)

@export var _e_time_between_chars: float = 0.03
@export var _e_read_time_per_char: float = 0.03
@export var _e_proceed_cd: float = 0.2
@export var _e_chars_per_vox: int = 3

var _a_Vox_Default = preload("res://Global_Resources/Audio/SFX/Vox/Default.ogg")

@onready var _a_Character_Timer = get_node("Character_Timer")
@onready var _a_Auto_Proceed = get_node("Auto_Proceed")
@onready var _a_Wait_Timer = get_node("Wait_Timer")
@onready var _a_Vox = get_node("Vox")

var _a_type = "" # Text/Info/Choice
var _a_process_type = "" # Main/Sub/Manual
var _a_args = {}

var _a_regex = RegEx.new()
var _a_text_finished = false
var _a_play_vox = true
var _a_fade_in = false
var _a_fade_out = false
var _a_text_args = {}

func _ready():
	_a_Character_Timer.timeout.connect(_on_Character_Timer_timeout)
	_a_Auto_Proceed.timeout.connect(_on_Auto_Proceed_timeout)
	_a_Wait_Timer.timeout.connect(_on_Wait_Timer_timeout)
	
	_set_data_vox()

func _set_data_vox():
	var data = _a_args["Data"][_a_type]["Vox"]
	var custom_active = data["Custom"]["Active"]
	if custom_active:
		var path = data["Custom"]["Path"]
		if !path.is_empty():
			var pitch = data["Custom"]["Pitch"]
			_a_Vox.set_stream(load(path))
			_a_Vox.set_pitch_scale(pitch)
	else:
		var object_key = data["Object"]
		var vox_data = Databases.get_data("Vox")
		if vox_data.has(object_key):
			# TODO
			pass
		else:
			_a_Vox.set_stream(_a_Vox_Default)

func reset():
	_a_Character_Timer.stop()
	_a_Auto_Proceed.stop()
	_a_Wait_Timer.stop()

func _handle_command(p_command, p_args):
	match p_command:
		"Wait":
			var time = float(p_args["Time"])
			_a_Character_Timer.stop()
			_a_Wait_Timer.start(time)

func _eval_command(p_command, p_args):
	match p_command:
		"Expr":
			var global_si = Global.get_singleton(self, "Global")
			return str(global_si.execute_expr_from_data(p_args))
		_:
			return ""

func set_type(p_type):
	_a_type = p_type

func set_process_type(p_process_type):
	_a_process_type = p_process_type

func set_args(p_args):
	_a_args = p_args

func get_args():
	return _a_args

func set_play_vox(p_value):
	_a_play_vox = p_value

func set_fade_in(p_fade_in):
	_a_fade_in = p_fade_in

func set_fade_out(p_fade_out):
	_a_fade_out = p_fade_out

func set_process_mode_(p_process_mode):
	set_process_mode(p_process_mode)

func _get_real_text(p_text):
	# Modify p_text to only contain text to display
	# Save args in a_text_args
	
	# Unescaped Pattern: ({\w+\s(?:\w+=(?:.*?)\s?)*})|(\[.*?\])
	_a_regex.compile("({\\w+\\s(?:\\w+=(?:.*?)\\s?)*})|(\\[.*?\\])")
	var custom_idx_offset = 0
	var bbcode_idx_offset = 0
	for res in _a_regex.search_all(p_text):
		var custom_text = res.get_string(1)
		var text = res.get_string(2)
		
		if !text.is_empty():
			var length = text.length()
			bbcode_idx_offset += length
		
		if !custom_text.is_empty():
			var start = res.get_start()
			var length = custom_text.length()
			var custom_real_start = start - custom_idx_offset
			var bbcode_real_start = custom_real_start - bbcode_idx_offset
			custom_text = custom_text.substr(1, length - 2)
			p_text = p_text.erase(custom_real_start, length)
			
			var main_args = custom_text.split(" ")
			var command = main_args[0]
			var command_args = {}
			for i in range(1, main_args.size()):
				var arg = main_args[i]
				var split = arg.split("=")
				var param = split[0]
				var value = split[1]
				command_args[param] = value
			
			var replace_text = _eval_command(command, command_args)
			if replace_text.is_empty():
				# This command replaces no text -> handle during cutscene
				var args = {}
				args["Command"] = command
				args["Args"] = command_args
				_a_text_args[str(bbcode_real_start)] = args
			else:
				p_text = p_text.insert(custom_real_start, replace_text)
				custom_idx_offset -= replace_text.length()
			
			custom_idx_offset += length
	
	return p_text

func _on_Character_Timer_timeout():
	pass

func _on_Auto_Proceed_timeout():
	pass

func _on_Wait_Timer_timeout():
	_a_Wait_Timer.stop()
	_a_Character_Timer.start()
