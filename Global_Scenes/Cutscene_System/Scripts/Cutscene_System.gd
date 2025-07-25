extends Node

signal main_started(p_key)
signal main_completed()
signal data_loaded()

@export var _e_thread_paths : Dictionary[String, Dictionary] = {}

var _a_Branch_Scene = preload("res://Global_Scenes/Cutscene_System/Branch.tscn")

@onready var _a_Branches = get_node("Branches")
@onready var _a_Skip_CD = get_node("Skip_CD")

var _a_save_data = {}

var _a_main_active = false
var _a_skipping_allowed = true
var _a_branches = {} # Match cutscene key/idx to branch instance

func _ready():
	_a_Skip_CD.timeout.connect(_on_Skip_CD_timeout)
	
	set_process(false)

func _process(_p_delta):
	if !OS.is_debug_build():
		return
	if !_a_skipping_allowed:
		return
	
	if Input.is_action_pressed("Skip"):
		for child in _a_Branches.get_children():
			var process_type = child.get_process_type()
			if process_type != "Main" && process_type != "Sub":
				continue
			
			child.skip()
			_a_skipping_allowed = false
			_a_Skip_CD.start()

func cutscene(p_key, p_entry_key, p_process_type = "Main", p_key_type = "Map"):
	# p_key: Cutscene key
	# p_entry_key: Cutscene Entry key
	# p_process_type: Main/Sub
	# p_key_type: Map/Global
	
	var cutscene_data = Databases.get_global_map_data("Cutscenes", p_key_type, "", "", self)
	var data = cutscene_data[p_key]["Data"][p_entry_key]["Data"]["Default"].duplicate(true)
	if !_a_main_active && p_process_type == "Main":
		_set_main_active(true)
		main_started.emit(p_key)
	
	var scene_manager_si = Global.get_singleton(self, "Scene_Manager")
	var curr_scene = scene_manager_si.get_curr_scene_instance()
	var instance = _instantiate_branch(curr_scene, data, p_process_type,
									   p_key, p_entry_key, p_key_type)
	_a_Branches.add_child(instance)

func cutscene_from_data(p_curr_scene, p_data, p_process_type, p_skip_idxs = []):
	if !_a_main_active && p_process_type == "Main":
		_set_main_active(true)
		main_started.emit("")
	
	var args = p_data.duplicate(true)
	var instance = _instantiate_branch(p_curr_scene, args, p_process_type,
									   "", "", "", p_skip_idxs)
	_a_Branches.add_child(instance)

func stop():
	for child in _a_Branches.get_children():
		child.queue_free()
	if !_a_main_active:
		return
	
	_set_main_active(false)
	main_completed.emit()

func reset():
	_a_save_data.clear()
	_a_main_active = false
	_a_Skip_CD.stop()
	_a_skipping_allowed = true
	for child in _a_Branches.get_children():
		child.queue_free()

func cleanup_map():
	for child in _a_Branches.get_children():
		child.cleanup_map()
		if !child.get_persist():
			child.queue_free()

func _branch_completed(p_instance):
	var main_active = false
	for child in _a_Branches.get_children():
		if !child.has_completed() && child.get_process_type() == "Main":
			main_active = true
			break
	
	var process_type = p_instance.get_process_type()
	var completed_cb = p_instance.get_completed_cb()
	if completed_cb.is_valid():
		var key = p_instance.get_key()
		var entry_key = p_instance.get_entry_key()
		completed_cb.call(process_type, key, entry_key)
	
	if !main_active:
		_set_main_active(false)
		if process_type == "Main":
			main_completed.emit()

func _instantiate_branch(p_curr_scene, p_data, p_process_type, p_key,
						 p_entry_key, p_key_type, p_skip_idxs = []):
	var instance = _a_Branch_Scene.instantiate()
	instance.command_changed.connect(_on_Branch_command_changed.bind(instance))
	instance.tree_exited.connect(_on_Branch_tree_exited)
	instance.tree_exiting.connect(_on_Branch_tree_exiting.bind(instance))
	instance.completed.connect(_on_Branch_completed.bind(instance))
	instance.request_exit.connect(_on_Branch_request_exit.bind(instance))
	instance.set_thread_paths(_e_thread_paths)
	instance.set_curr_scene(p_curr_scene)
	instance.set_data(p_data)
	instance.set_process_type(p_process_type)
	instance.set_key(p_key)
	instance.set_entry_key(p_entry_key)
	instance.set_key_type(p_key_type)
	instance.set_skip_idxs(p_skip_idxs)
	
	if !p_key.is_empty():
		if !_a_branches.has(p_key):
			_a_branches[p_key] = {}
		_a_branches[p_key][p_entry_key] = instance
	
	return instance

func get_option_value(p_data):
	var type = p_data["Type"]
	match type:
		"Var":
			var global_si = Global.get_singleton(self, "Global")
			var expression_data = p_data["Var"]["Expression"]
			return global_si.execute_expr_from_data(expression_data)
		"Value":
			return p_data["Value"]

func get_movement_base_speed(p_dim, p_speed_key):
	match p_dim:
		"2D": return get_movement_base_speed_2D(p_speed_key)
		"3D": return get_movement_base_speed_3D(p_speed_key)

func get_movement_base_speed_2D(p_speed_key):
	match p_speed_key:
		"Very_Slow": return 2.0
		"Slow": return 4.0
		"Normal": return 1.0
		"Fast": return 8.0
		"Very_Fast": return 10.0

func get_movement_base_speed_3D(p_speed_key):
	match p_speed_key:
		"Very_Slow": return 0.25
		"Slow": return 0.5
		"Normal": return 1.0
		"Fast": return 1.5
		"Very_Fast": return 2.0

func get_movement_duration_factor(p_dim, p_speed_key):
	match p_dim:
		"2D": return get_movement_duration_factor_2D(p_speed_key)
		"3D": return get_movement_duration_factor_3D(p_speed_key)

func get_movement_duration_factor_2D(p_speed_key):
	match p_speed_key:
		"Very_Slow": return 65.0
		"Slow": return 100.0
		"Normal": return 135.0
		"Fast": return 200.0
		"Very_Fast": return 265.0

func get_movement_duration_factor_3D(p_speed_key):
	match p_speed_key:
		"Very_Slow": return 1.3
		"Slow": return 2.0
		"Normal": return 2.7
		"Fast": return 4.0
		"Very_Fast": return 5.3

func set_cutscene_completed_cb(p_key, p_entry_key, p_completed_cb):
	var instance = _a_branches[p_key][p_entry_key]
	instance.set_completed_cb(p_completed_cb)

func set_cutscene_process_mode(p_key, p_entry_key, p_process_mode):
	var instance = _a_branches[p_key][p_entry_key]
	instance.set_process_mode_(p_process_mode)

func set_cutscene_caller(p_key, p_entry_key, p_caller):
	var instance = _a_branches[p_key][p_entry_key]
	instance.set_caller(p_caller)

func get_cutscene_caller(p_key, p_entry_key):
	var branch = _a_branches[p_key][p_entry_key]
	var caller = branch.get_caller()
	
	return caller

func get_cutscene_caller_key(p_key, p_entry_key):
	var caller = get_cutscene_caller(p_key, p_entry_key)
	var key = caller.comph().call_comp("Reference", "get_key")
	
	return key

func _set_main_active(p_active):
	_a_main_active = p_active
	set_process(p_active)

func get_save_data(p_location, p_for_file):
	_a_save_data[p_location] = {}
	var data = _a_save_data[p_location]
	
	data["Branches"] = []
	for child in _a_Branches.get_children():
		var save_data = child.get_save_data(p_for_file)
		data["Branches"].push_back(save_data)
		
		if !p_for_file && !child.get_persist():
			child.queue_free()
	
	return _a_save_data

func load_file_data(p_data):
	_a_save_data = p_data

func load_data(p_location, p_for_file):
	if !_a_save_data.has(p_location):
		data_loaded.emit()
		return
	
	var save_data = _a_save_data[p_location]
	var branches_data = save_data["Branches"]
	for i in branches_data.size():
		var args = branches_data[i]
		
		var instance = null
		var process_type = ""
		var key = ""
		var persist = args["General"]["Persist"]
		if !p_for_file && persist:
			# The branch still exists
			var self_path = args["General"]["Self_Path"]
			instance = get_node(self_path)
			process_type = instance.get_process_type()
			key = instance.get_key()
		else:
			# Create new branch
			process_type = args["General"]["Process_Type"]
			key = args["General"]["Key"]
			
			var entry_key = args["General"]["Entry_Key"]
			var key_type = args["General"]["Key_Type"]
			var cutscene_data = Databases.get_global_map_data("Cutscenes", key_type, "", "", self)
			var data = cutscene_data[key]["Data"][entry_key]["Data"]["Default"].duplicate(true)
			var caller_path = args["General"]["Caller_Path"]
			var caller = get_node_or_null(caller_path)
			
			var scene_manager_si = Global.get_singleton(self, "Scene_Manager")
			var curr_scene = scene_manager_si.get_curr_scene_instance()
			instance = _instantiate_branch(curr_scene, data, process_type,
										   key, entry_key, key_type)
			set_cutscene_caller(key, entry_key, caller)
		
		if !_a_main_active && process_type == "Main":
			_set_main_active(true)
			main_started.emit(key)
		
		if i == branches_data.size() - 1:
			instance.data_loaded.connect(_on_Branches_data_loaded)
		instance.set_loads_data(true)
		instance.load_data(args, p_for_file)
		
		if !persist || p_for_file:
			_a_Branches.add_child(instance)
	
	if branches_data.is_empty():
		data_loaded.emit()

func _on_Skip_CD_timeout():
	_a_skipping_allowed = true

func _on_Branch_command_changed(p_instance):
	var command = p_instance.get_command()
	var idx = p_instance.get_index()
	p_instance.set_name("%s_%d" % [command, idx])

func _on_Branch_tree_exited():
	for child in _a_Branches.get_children():
		var command = child.get_command()
		var idx = child.get_index()
		child.set_name("%s_%d" % [command, idx])

func _on_Branch_tree_exiting(p_instance):
	var key = p_instance.get_key()
	if !key.is_empty():
		var entry_key = p_instance.get_entry_key()
		_a_branches[key].erase(entry_key)
		if _a_branches[key].is_empty():
			_a_branches.erase(key)

func _on_Branch_completed(p_instance):
	_branch_completed(p_instance)

func _on_Branch_request_exit(p_instance):
	_branch_completed(p_instance)
	p_instance.queue_free()

func _on_Branches_data_loaded():
	data_loaded.emit()
