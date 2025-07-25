extends "res://Scripts/Extension_Base.gd"

var _a_type = ""
var _a_dirs = []
var _a_match_dir = true
var _a_popup_type = ""
var _a_popup_pos = null # Vector
var _a_speech_bubble_pos = null # Vector
var _a_cutscene_process_type = ""
var _a_cutscene_key_type = ""
var _a_cutscene_args = []
var _a_cutscene_args_idx = -1
var _a_dialogue_process_type = ""
var _a_dialogue_fade_out = false
var _a_dialogue_start_idx = -1
var _a_dialogue_end_idx = -1
var _a_dialogue_key_type = ""
var _a_dialogue_args = []
var _a_dialogue_args_idx = -1
var _a_active = false # Does Player interact with this?
var _a_interaction_count = 0 # Player interaction count

func increase_dialogue_args_idx(p_value):
	var size = _a_dialogue_args.size()
	_a_dialogue_args_idx = (_a_dialogue_args_idx + p_value) % size

func increase_cutscene_args_idx(p_value):
	var size = _a_cutscene_args.size()
	_a_cutscene_args_idx = (_a_cutscene_args_idx + p_value) % size

func increase_interaction_count():
	_a_interaction_count += 1

func set_type(p_type):
	_a_type = p_type

func get_type():
	return _a_type

func set_dirs(p_dirs):
	_a_dirs = p_dirs

func get_dirs():
	return _a_dirs

func set_match_dir(p_match_dir):
	_a_match_dir = p_match_dir

func get_match_dir():
	return _a_match_dir

func set_popup_type(p_popup_type):
	_a_popup_type = p_popup_type

func get_popup_type():
	return _a_popup_type

func set_popup_pos(p_popup_pos):
	_a_popup_pos = p_popup_pos

func get_popup_pos():
	return _a_popup_pos

func set_speech_bubble_pos(p_speech_bubble_pos):
	_a_speech_bubble_pos = p_speech_bubble_pos

func get_speech_bubble_pos():
	return _a_speech_bubble_pos

func set_cutscene_process_type(p_cutscene_process_type):
	_a_cutscene_process_type = p_cutscene_process_type

func get_cutscene_process_type():
	return _a_cutscene_process_type

func set_cutscene_key_type(p_cutscene_key_type):
	_a_cutscene_key_type = p_cutscene_key_type

func get_cutscene_key_type():
	return _a_cutscene_key_type

func set_cutscene_args(p_cutscene_args):
	_a_cutscene_args = p_cutscene_args
	_a_cutscene_args_idx = 0

func get_cutscene_args():
	return _a_cutscene_args

func set_cutscene_args_idx(p_cutscene_args_idx):
	_a_cutscene_args_idx = p_cutscene_args_idx

func get_cutscene_args_idx():
	return _a_cutscene_args_idx

func set_dialogue_process_type(p_dialogue_process_type):
	_a_dialogue_process_type = p_dialogue_process_type

func get_dialogue_process_type():
	return _a_dialogue_process_type

func set_dialogue_fade_out(p_dialogue_fade_out):
	_a_dialogue_fade_out = p_dialogue_fade_out

func get_dialogue_fade_out():
	return _a_dialogue_fade_out

func set_dialogue_start_idx(p_dialogue_start_idx):
	_a_dialogue_start_idx = p_dialogue_start_idx

func get_dialogue_start_idx():
	return _a_dialogue_start_idx

func set_dialogue_end_idx(p_dialogue_end_idx):
	_a_dialogue_end_idx = p_dialogue_end_idx

func get_dialogue_end_idx():
	return _a_dialogue_end_idx

func set_dialogue_key_type(p_dialogue_key_type):
	_a_dialogue_key_type = p_dialogue_key_type

func get_dialogue_key_type():
	return _a_dialogue_key_type

func set_dialogue_args(p_dialogue_args):
	_a_dialogue_args = p_dialogue_args
	_a_dialogue_args_idx = 0

func get_dialogue_args():
	return _a_dialogue_args

func set_dialogue_args_idx(p_dialogue_args_idx):
	_a_dialogue_args_idx = p_dialogue_args_idx

func get_dialogue_args_idx():
	return _a_dialogue_args_idx

func is_at_last_dialogue_args():
	return _a_dialogue_args_idx == _a_dialogue_args.size() - 1

func set_active(p_active):
	_a_active = p_active

func is_active():
	return _a_active

func set_interaction_count(p_interaction_count):
	_a_interaction_count = p_interaction_count

func get_interaction_count():
	return _a_interaction_count
