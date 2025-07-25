extends Area3D

@export_enum("Walk_In", "Press_Key") var _e_type = "Press_Key"
@export var _e_dirs: Array[String] = ["Down", "Up", "Left", "Right"]
@export var _e_match_dir: bool = true # Does Player have to match dir to interact?
@export_enum("Exclamation", "Question", "Speech", "None") var _e_popup_type = "Speech"
@export var _e_popup_pos: Vector3 = Vector3.ZERO
@export var _e_speech_bubble_pos: Vector3 = Vector3.ZERO
@export_enum("Main", "Sub") var _e_cutscene_process_type: String = "Main"
@export_enum("Map", "Global") var _e_cutscene_key_type: String = "Map"
@export var _e_cutscene_args: Array[Array] = [] # (Array, Array)
@export var _e_cutscene_args_idx: int = 0
@export_enum("Main", "Sub") var _e_dialogue_process_type: String = "Main"
@export var _e_dialogue_fade_out: bool = true
@export var _e_dialogue_start_idx: int = 0
@export var _e_dialogue_end_idx: int = -1
@export_enum("Map", "Global") var _e_dialogue_key_type: String = "Map"
@export var _e_dialogue_args: Array[String] = []
@export var _e_dialogue_args_idx: int = 0

var _a_Shared = preload("res://Scenes/Object/Comps/Interactions/Interaction/Scripts/Shared.gd")

var _a_shared = null

func _ready():
	_a_shared = _a_Shared.new(self)
	_a_shared.set_type(_e_type)
	_a_shared.set_dirs(_e_dirs)
	_a_shared.set_match_dir(_e_match_dir)
	_a_shared.set_popup_type(_e_popup_type)
	_a_shared.set_popup_pos(_e_popup_pos)
	_a_shared.set_speech_bubble_pos(_e_speech_bubble_pos)
	_a_shared.set_cutscene_process_type(_e_cutscene_process_type)
	_a_shared.set_cutscene_key_type(_e_cutscene_key_type)
	_a_shared.set_cutscene_args(_e_cutscene_args)
	_a_shared.set_cutscene_args_idx(_e_cutscene_args_idx)
	_a_shared.set_dialogue_process_type(_e_dialogue_process_type)
	_a_shared.set_dialogue_fade_out(_e_dialogue_fade_out)
	_a_shared.set_dialogue_start_idx(_e_dialogue_start_idx)
	_a_shared.set_dialogue_end_idx(_e_dialogue_end_idx)
	_a_shared.set_dialogue_key_type(_e_dialogue_key_type)
	_a_shared.set_dialogue_args(_e_dialogue_args)
	_a_shared.set_dialogue_args_idx(_e_dialogue_args_idx)

func increase_cutscene_args_idx(p_value):
	_a_shared.increase_cutscene_args_idx(p_value)

func increase_dialogue_args_idx(p_value):
	_a_shared.increase_dialogue_args_idx(p_value)

func is_at_last_dialogue_args():
	return _a_shared.is_at_last_dialogue_args()

func increase_interaction_count():
	_a_shared.increase_interaction_count()

func set_type(p_type):
	_a_shared.set_type(p_type)

func get_type():
	return _a_shared.get_type()

func set_dirs(p_dirs):
	_a_shared.set_dirs(p_dirs)

func get_dirs():
	return _a_shared.get_dirs()

func set_match_dir(p_match_dir):
	_a_shared.set_match_dir(p_match_dir)

func get_match_dir():
	return _a_shared.get_match_dir()

func set_popup_type(p_popup_type):
	_a_shared.set_popup_type(p_popup_type)

func get_popup_type():
	return _a_shared.get_popup_type()

func get_popup_pos():
	return _a_shared.get_popup_pos()

func get_speech_bubble_pos():
	return _a_shared.get_speech_bubble_pos()

func get_cutscene_process_type():
	return _a_shared.get_cutscene_process_type()

func get_cutscene_key_type():
	return _a_shared.get_cutscene_key_type()

func set_cutscene_args(p_cutscene_args):
	_a_shared.set_cutscene_args(p_cutscene_args)

func get_cutscene_args():
	return _a_shared.get_cutscene_args()

func set_cutscene_args_idx(p_cutscene_args_idx):
	_a_shared.set_cutscene_args_idx(p_cutscene_args_idx)

func get_cutscene_args_idx():
	return _a_shared.get_cutscene_args_idx()

func get_dialogue_process_type():
	return _a_shared.get_dialogue_process_type()

func get_dialogue_fade_out():
	return _a_shared.get_dialogue_fade_out()

func get_dialogue_start_idx():
	return _a_shared.get_dialogue_start_idx()

func get_dialogue_end_idx():
	return _a_shared.get_dialogue_end_idx()

func get_dialogue_key_type():
	return _a_shared.get_dialogue_key_type()

func set_dialogue_args(p_dialogue_args):
	_a_shared.set_dialogue_args(p_dialogue_args)

func get_dialogue_args():
	return _a_shared.get_dialogue_args()

func set_dialogue_args_idx(p_dialogue_args_idx):
	_a_shared.set_dialogue_args_idx(p_dialogue_args_idx)

func get_dialogue_args_idx():
	return _a_shared.get_dialogue_args_idx()

func set_active(p_active):
	_a_shared.set_active(p_active)

func is_active():
	return _a_shared.is_active()

func set_interaction_count(p_interaction_count):
	_a_shared.set_interaction_count(p_interaction_count)

func get_interaction_count():
	return _a_shared.get_interaction_count()
