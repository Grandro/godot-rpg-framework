extends Node

signal main_started(p_key)
signal main_completed()

var _a_Thread_Scene = preload("res://Global_Scenes/Dialogue_System/Thread/Thread.tscn")

@onready var _a_Threads = get_node("Threads")

var _a_save_data = {}

var _a_main_active = false
var _a_threads = {} # Match dialogue key to thread instance

func dialogue(p_key, p_caller = null, p_process_type = "Main", p_fade_out = true,
			  p_start_idx = 0, p_end_idx = -1, p_key_type = "Map"):
	# p_key: Dialogue key
	# p_caller: Caller of dialogue
	# p_process_type: Main/Sub
	# p_fade_out: Fade out on dialogue completion?
	# p_key_type: Map/Global?
	
	var instance = _instantiate_thread(p_key, p_caller, p_process_type, p_start_idx,
									   p_end_idx, p_fade_out, p_key_type, "Key")
	_update_threads_vox(instance, p_process_type)
	
	if !_a_main_active && p_process_type == "Main":
		_a_main_active = true
		main_started.emit(p_key)
	
	_a_Threads.add_child(instance)

func dialogue_speech_bubbles(p_key, p_speech_bubbles, p_caller = null, p_process_type = "Main",
							p_start_idx = 0, p_end_idx = -1, p_fade_out = true, p_key_type = "Map"):
	# p_key : Dialogue key
	# p_caller : Callback instance
	# p_process_type : Main/Sub
	# p_fade_out : Fade out on dialogue completion?
	# p_key_type : Map/Global Key in Chapter/Location or Global?
	
	var instance = _instantiate_thread(p_key, p_caller, p_process_type, p_start_idx,
									   p_end_idx, p_fade_out, p_key_type, "Speech_Bubble",
									   p_speech_bubbles)
	_update_threads_vox(instance, p_process_type)
	
	if !_a_main_active && p_process_type == "Main":
		_a_main_active = true
		main_started.emit(p_key)
	
	_a_Threads.add_child(instance)

func manual_proceed(p_key):
	var thread = _a_threads[p_key]
	thread.manual_proceed()

func skip(p_key):
	var thread = _a_threads[p_key]
	thread.skip()

func stop():
	_a_threads.clear()
	for child in _a_Threads.get_children():
		child.queue_free()
	
	if _a_main_active:
		main_completed.emit()
		_a_main_active = false

func _instantiate_thread(p_key, p_caller, p_process_type, p_start_idx, p_end_idx,
						 p_fade_out, p_key_type, p_instances_type, p_speech_bubbles = []):
	var instance = _a_Thread_Scene.instantiate()
	instance.completed.connect(_on_Thread_completed.bind(instance))
	instance.set_key(p_key)
	instance.set_caller(p_caller)
	instance.set_process_type(p_process_type)
	instance.set_start_idx(p_start_idx)
	instance.set_end_idx(p_end_idx)
	instance.set_fade_out(p_fade_out)
	instance.set_key_type(p_key_type)
	instance.set_instances_type(p_instances_type)
	instance.set_speech_bubbles(p_speech_bubbles)
	
	_a_threads[p_key] = instance
	
	return instance

func _update_threads_vox(p_instance, p_process_type):
	if p_process_type == "Main":
		# Tell all other threads to mute vox
		for child in _a_Threads.get_children():
			child.set_play_vox(false)
	
	elif p_process_type == "Sub" || p_process_type == "Manual":
		# Only play vox if there is no vox playback already
		for child in _a_Threads.get_children():
			if child.get_play_vox():
				p_instance.set_play_vox.call_deferred(false)
				break

func set_dialogue_process_mode(p_key, p_process_mode):
	var instance = _a_threads[p_key]
	instance.set_process_mode_(p_process_mode)

func set_dialogue_layer(p_key, p_layer):
	var instance = _a_threads[p_key]
	instance.set_layer(p_layer)

func set_dialogue_completed_cb(p_key, p_completed_cb):
	var instance = _a_threads[p_key]
	instance.set_completed_cb(p_completed_cb)

func set_dialogue_choice_selected_cb(p_key, p_choice_selected_cb):
	var instance = _a_threads[p_key]
	instance.set_choice_selected_cb(p_choice_selected_cb)

func get_save_data(p_location, p_for_file):
	_a_save_data[p_location] = {}
	var data = _a_save_data[p_location]
	
	data["Main_Active"] = _a_main_active
	data["Threads"] = []
	for child in _a_Threads.get_children():
		var save_data = child.get_save_data()
		data["Threads"].push_back(save_data)
		
		if !p_for_file:
			child.queue_free()
	
	return _a_save_data

func load_file_data(p_data):
	_a_save_data = p_data

func load_data(p_location):
	if !_a_save_data.has(p_location):
		return
	
	var save_data = _a_save_data[p_location]
	_a_main_active = save_data["Main_Active"]
	
	for args in save_data["Threads"]:
		var key_type = args["Key_Type"]
		var key = args["Key"]
		var process_type = args["Process_Type"]
		var idx = args["Idx"]
		var start_idx = args["Start_Idx"]
		var end_idx = args["End_Idx"]
		var fade_out = args["Fade_Out"]
		var caller_path = args["Caller_Path"]
		var caller = get_node_or_null(caller_path)
		var completed_cb_object_path = args["Completed_CB"]["Object_Path"]
		var completed_cb_object = get_node_or_null(completed_cb_object_path)
		var completed_cb = Callable()
		if completed_cb_object != null:
			var completed_cb_name = args["Completed_CB"]["Name"]
			completed_cb = Callable(completed_cb_object, completed_cb_name)
		var choice_selected_cb_object_path = args["Choice_Selected_CB"]["Object_Path"]
		var choice_selected_cb_object = get_node_or_null(choice_selected_cb_object_path)
		var choice_selected_cb = Callable()
		if choice_selected_cb_object != null:
			var choice_selected_cb_name = args["Choice_Selected_CB"]["Name"]
			choice_selected_cb = Callable(choice_selected_cb_object, choice_selected_cb_name)
		#var instances_type = args["Instances_Type"]
		#var speech_bubbles = args["Speech_Bubbles"]
		
		if !_a_main_active && process_type == "Main":
			_a_main_active = true
			main_started.emit(key)
		
		var instance = _instantiate_thread(key, caller, process_type, start_idx,
										   end_idx, fade_out, key_type, "Key")
		instance.set_idx(idx)
		_update_threads_vox(instance, process_type)
		instance.set_process_mode_.call_deferred(args["Process_Mode"])
		instance.set_layer.call_deferred(args["Layer"])
		instance.set_completed_cb(completed_cb)
		instance.set_choice_selected_cb(choice_selected_cb)
		
		_a_Threads.add_child(instance)

func _on_Thread_completed(p_instance):
	_a_Threads.remove_child(p_instance)
	
	var key = p_instance.get_key()
	var process_type = p_instance.get_process_type()
	if process_type == "Main":
		# Give vox playback to latest main,
		# if there is none choose latest non-main
		var latest_main = null
		var latest_non_main = null
		var children = _a_Threads.get_children()
		for i in range(children.size() - 1, -1, -1):
			var child = children[i]
			var child_process_type = child.get_process_type()
			if latest_main == null && child_process_type == "Main":
				latest_main = child
			if latest_non_main == null && child_process_type != "Main":
				latest_non_main = child
			if latest_main != null && latest_non_main != null:
				break
		
		if latest_main == null:
			if latest_non_main != null:
				latest_non_main.set_play_vox(true)
			
			main_completed.emit()
			_a_main_active = false
		else:
			latest_main.set_play_vox(true)
	
	elif process_type == "Sub" || process_type == "Manual":
		# If there is no main active latest non-main needs vox playback
		var children = _a_Threads.get_children()
		if !_a_main_active:
			for i in range(children.size() - 1, -1, -1):
				var child = children[i]
				if child.get_process_type() != "Main":
					child.set_play_vox(true)
					break
	
	_a_threads.erase(key)
	
	var completed_cb = p_instance.get_completed_cb()
	if completed_cb.is_valid():
		completed_cb.call(key)
