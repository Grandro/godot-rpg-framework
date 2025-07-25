extends Node

signal completed()

const _a_PROCESS_SCENE_PATH = "res://Global_Scenes/Dialogue_System/Thread/Process/Process_%s.tscn"

@onready var _a_Processes = get_node("Processes")

var _a_key_type = "" # Map/Global
var _a_key = "" # Dialogue Key
var _a_caller = null # Caller of Dialogue_System
var _a_completed_cb = Callable() # Callback method to call on completion
var _a_choice_selected_cb = Callable() # Callback method to call on choice selected
var _a_process_type = "" # Main/Sub/Manual
var _a_idx = -1 # Current part idx
var _a_start_idx = -1 # Start part idx
var _a_end_idx = -1 # End part idx
var _a_layer = -1 # Layer of Process
var _a_fade_out = true # Play Fade_Out Animation on finish?
var _a_instances_type = "" # Key/Speech_Bubble
var _a_speech_bubbles = [] # Only needed if a_instances_type is Speech_Bubble

var _a_parts = []
var _a_play_vox = true

func _ready():
	var dialogues_data = Databases.get_global_map_data("Dialogues", _a_key_type, "", "", self)
	var data = dialogues_data[_a_key]["Data"]
	for args in data.values():
		_a_parts.push_back(args)
	
	# Set default values for idxs
	if _a_idx == -1:
		_a_idx = _a_start_idx
	if _a_end_idx == -1:
		_a_end_idx = _a_parts.size() - 1
	
	_process_next()

func manual_proceed():
	var child = _a_Processes.get_child(0)
	child.queue_free()
	
	_proceed()

func skip():
	var child = _a_Processes.get_child(0)
	var args = child.get_args()
	var type = args["Type"]
	var is_choice = type == "Choice"
	if is_choice:
		return
	
	child.reset()
	for i in range(_a_idx + 1, _a_end_idx):
		type = _a_parts[i]["Type"]
		if type == "Choice":
			_a_idx = i
			_process_next()
			return
	
	queue_free()
	completed.emit()

func _process_next():
	var args = _a_parts[_a_idx]
	var type = args["Type"]
	var instance = _instantiate_process(args, type)
	instance.set_fade_in(_get_fade_in(args, type))
	instance.set_fade_out(_get_fade_out(args, type))
	
	_a_Processes.add_child(instance)

func _proceed():
	_a_idx += 1
	if _a_idx > _a_end_idx:
		queue_free()
		completed.emit()
		return
	
	_process_next()

func _instantiate_process(p_args, p_type):
	var instance = null
	match p_type:
		"Text":
			var general_type = p_args["Data"]["Text"]["General"]["Type"]
			instance = _instantiate_process_text(p_type, general_type)
		_:
			var scene = load(_a_PROCESS_SCENE_PATH % p_type)
			instance = scene.instantiate()
	
	instance.choice_selected.connect(_on_Process_choice_selected)
	instance.completed.connect(_on_Process_completed)
	instance.set_type(p_type)
	instance.set_process_type(_a_process_type)
	instance.set_args(p_args)
	instance.set_play_vox(_a_play_vox)
	instance.set_process_mode_.call_deferred(process_mode)
	instance.set_layer(_a_layer)
	
	return instance

func _instantiate_process_text(p_type, p_general_type):
	var process_name = "%s_%s" % [p_type, p_general_type]
	var scene = load(_a_PROCESS_SCENE_PATH % process_name)
	var instance = scene.instantiate()
	match p_general_type:
		"Object":
			instance.set_instance_type(_a_instances_type)
			
			# Pass Process instance provided speech bubble instance
			if _a_instances_type == "Speech_Bubble":
				var speech_bubble = null
				if _a_idx > _a_speech_bubbles.size() - 1:
					speech_bubble = _a_speech_bubbles[-1]
				else:
					speech_bubble = _a_speech_bubbles[_a_idx]
				instance.set_speech_bubble(speech_bubble)
	
	return instance

func set_key(p_key):
	_a_key = p_key

func get_key():
	return _a_key

func set_caller(p_caller):
	_a_caller = p_caller

func get_caller():
	return _a_caller

func set_completed_cb(p_completed_cb):
	_a_completed_cb = p_completed_cb

func get_completed_cb():
	return _a_completed_cb

func set_choice_selected_cb(p_choice_selected_cb):
	_a_choice_selected_cb = p_choice_selected_cb

func get_choice_selected_cb():
	return _a_choice_selected_cb

func set_process_mode_(p_process_mode):
	set_process_mode(p_process_mode)
	for child in _a_Processes.get_children():
		child.set_process_mode_(p_process_mode)

func set_layer(p_layer):
	_a_layer = p_layer
	for child in _a_Processes.get_children():
		child.set_layer(p_layer)

func set_process_type(p_process_type):
	_a_process_type = p_process_type

func get_process_type():
	return _a_process_type

func set_idx(p_idx):
	_a_idx = p_idx

func set_start_idx(p_start_idx):
	_a_start_idx = p_start_idx

func set_end_idx(p_end_idx):
	_a_end_idx = p_end_idx

func set_fade_out(p_fade_out):
	_a_fade_out = p_fade_out

func set_key_type(p_key_type):
	_a_key_type = p_key_type

func set_instances_type(p_instances_type):
	_a_instances_type = p_instances_type

func set_speech_bubbles(p_speech_bubbles):
	_a_speech_bubbles = p_speech_bubbles

func set_play_vox(p_value):
	for child in _a_Processes.get_children():
		child.set_play_vox(p_value)
	
	_a_play_vox = p_value

func get_play_vox():
	return _a_play_vox

func _get_fade_in(p_args, p_type):
	# First Part
	if _a_idx == _a_start_idx:
		return true
	
	# Previous type different
	var prev_args = _a_parts[_a_idx - 1]
	var prev_type = prev_args["Type"]
	if prev_type != p_type:
		return true
	
	if p_type == "Text":
		var general_type = p_args["Data"][p_type]["General"]["Type"]
		var prev_general_type = prev_args["Data"][p_type]["General"]["Type"]
		# Previous general type different
		if prev_general_type != general_type:
			return true
		
		# Previous object key different
		var object_key = p_args["Data"][p_type]["Object"]["Object"]
		var prev_object_key = prev_args["Data"][p_type]["Object"]["Object"]
		if prev_object_key != object_key:
			return true
	
	return false

func _get_fade_out(p_args, p_type):
	# Fade out if:
	# - Next part is different type
	# (If type Text_Object also object key can be different)
	
	# Last part and a_fade_out
	if _a_idx == _a_end_idx:
		return _a_fade_out
	
	# Next type different
	var next_args = _a_parts[_a_idx + 1]
	var next_type = next_args["Type"]
	if next_type != p_type:
		return true
	
	if p_type == "Text":
		var general_type = p_args["Data"][p_type]["General"]["Type"]
		var next_general_type = next_args["Data"][p_type]["General"]["Type"]
		# Next general type different
		if next_general_type != general_type:
			return true
		
		# Next object key different
		var object_key = p_args["Data"][p_type]["Object"]["Object"]
		var next_object_key = next_args["Data"][p_type]["Object"]["Object"]
		if next_object_key != object_key:
			return true
	
	return false

func get_save_data():
	var data = {}
	data["Key_Type"] = _a_key_type
	data["Key"] = _a_key
	
	var caller_path = NodePath()
	if is_instance_valid(_a_caller):
		caller_path = _a_caller.get_path()
	data["Caller_Path"] = caller_path
	
	var completed_cb_object_path = NodePath()
	var completed_cb_name = ""
	if _a_completed_cb.is_valid():
		var completed_cb_object = _a_completed_cb.get_object()
		completed_cb_object_path = completed_cb_object.get_path()
		completed_cb_name = _a_completed_cb.get_method()
	data["Completed_CB"] = {}
	data["Completed_CB"]["Object_Path"] = completed_cb_object_path
	data["Completed_CB"]["Name"] = completed_cb_name
	
	var choice_selected_cb_object_path = NodePath()
	var choice_selected_cb_name = ""
	if _a_choice_selected_cb.is_valid():
		var choice_selected_cb_object = _a_choice_selected_cb.get_object()
		choice_selected_cb_object_path = choice_selected_cb_object.get_path()
		choice_selected_cb_name = _a_choice_selected_cb.get_method()
	data["Choice_Selected_CB"] = {}
	data["Choice_Selected_CB"]["Object_Path"] = choice_selected_cb_object_path
	data["Choice_Selected_CB"]["Name"] = choice_selected_cb_name
	
	data["Process_Type"] = _a_process_type
	data["Process_Mode"] = get_process_mode()
	data["Idx"] = _a_idx
	data["Start_Idx"] = _a_start_idx
	data["End_Idx"] = _a_end_idx
	data["Layer"] = _a_layer
	data["Fade_Out"] = _a_fade_out
	data["Instances_Type"] = _a_instances_type
	data["Speech_Bubbles"] = _a_speech_bubbles
	
	return data

func _on_Process_choice_selected(p_value):
	if _a_choice_selected_cb.is_valid():
		_a_choice_selected_cb.call(_a_key, p_value)
	
	var progress_si = Global.get_singleton(self, "Progress")
	progress_si.set_dialogue_choice_value(_a_key_type, _a_key, _a_idx, p_value)

func _on_Process_completed():
	_proceed()
