extends Node

signal command_changed()
signal completed()
signal sub_process_completed(p_id_ord)
signal request_exit()
signal data_loaded()
signal persist_changed()

var _a_Branch_Scene = load("res://Global_Scenes/Cutscene_System/Branch.tscn")

@onready var _a_Branches = get_node("Branches")
@onready var _a_Threads = get_node("Threads")

var _a_thread_paths = {} # Scene paths to Threads 2D/3D
var _a_dim = "" # 2D/3D
var _a_curr_scene = null # Current scene instance
var _a_command = "" # Command of current thread
var _a_process_type = "" # Main/Sub/Stater
var _a_key = "" # Cutscene key
var _a_entry_key = "" # Cutscene Entry key
var _a_key_type = "" # Global/Map
var _a_caller = null # Caller of Cutscene_System
var _a_completed_cb = Callable() # Callback method to call on completion
var _a_skip_idxs = [] # Stores to which command this branch should skip
var _a_skip = false # Skip this branch?

var _a_data_origin = [] # Where in the original cutscene data does this data come from?
var _a_data = [] # Command data of this branch
var _a_data_idx = -1 # Command idx in _a_data to process
var _a_completed = false # Main branch has finished

var _a_persist = false # Don't delete this branch on map change
var _a_loads_data = false # Don't process next command if this loads data

var _a_branches_loaded = false # Finished loading branches?
var _a_threads_loaded = false # Finished loading threads?

# Additional arguments for certain commands
# Teleport
var _a_tp_type = ""
var _a_tp_branches = {}
var _a_tp_teleportation = ""
var _a_tp_return_location = ""
var _a_tp_handle_lost_battle = false
var _a_tp_branch = -1

# Loop
var _a_l_key = ""
var _a_l_first = true # First iteration of loop?
# Loop_For
var _a_lf_step = -1
var _a_lf_iters = -1

# Sub_Process
var _a_id = -1
# ------------------------------------

func _ready():
	var scene_manager_si = Global.get_singleton(self, "Scene_Manager")
	scene_manager_si.scene_changed.connect(_on_Scene_Manager_scene_changed)
	
	_a_dim = scene_manager_si.get_curr_scene_dim()
	if _a_data.is_empty():
		_a_completed = true
		completed.emit()
		queue_free()
		return
	
	if !_a_loads_data:
		_process_next_command(true)

func skip():
	for child in _a_Branches.get_children():
		child.skip.call_deferred()
	for child in _a_Threads.get_children():
		child.skip.call_deferred()

func cleanup_map():
	for child in _a_Branches.get_children():
		child.cleanup_map()
		if !child.get_persist():
			child.queue_free()

func handle_sub_process_threads(p_id):
	for child in _a_Threads.get_children():
		var command = child.get_command()
		if command == "Wait_For_Sub_Process":
			child.sub_process_completed(p_id)

func _process_next_command(p_inc):
	if p_inc:
		_a_data_idx += 1
	
	if _a_data_idx == _a_data.size():
		_a_completed = true
		completed.emit()
		return
	
	var data = _a_data[_a_data_idx]
	_a_command = data["Command"]
	command_changed.emit()
	
	if _a_skip_idxs.size() == 1:
		var idx = _a_skip_idxs[0]
		_a_skip = idx > _a_data_idx
	elif _a_skip_idxs.size() >= 2:
		_a_skip = true
	
	if _a_skip && _a_data_idx % 100 == 0:
		# Fight Stack Overflow
		await get_tree().process_frame
	
	match _a_command:
		"Cond_Branch": _process_cond_branch(data["Data"], data["Args"])
		"Teleport": _process_teleport(data["Data"], data["Args"])
		"Match": _process_match(data["Data"], data["Args"])
		"Loop": _process_loop(data["Data"], data["Args"])
		"Sub_Process": _process_sub_process(data["Data"], data["Args"])
		_: 
			var instance = _instantiate_thread(data["Data"], _a_command)
			_a_Threads.add_child(instance)

func _process_cond_branch(p_data, p_args):
	# Execute condition and instance new branch
	var global_si = Global.get_singleton(self, "Global")
	var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
	var key = p_data["Key"]
	var else_branch = p_data["Else_Branch"]
	var menu_data = p_data["Menus"][key]
	var branch = -1
	match key:
		"Items":
			var item_key = cutscene_system_si.get_option_value(menu_data["Item"])
			var amount_args = cutscene_system_si.get_option_value(menu_data["Amount"])
			var item_min = cutscene_system_si.get_option_value(amount_args["Min"])
			var item_max = cutscene_system_si.get_option_value(amount_args["Max"])
			var has_item = global_si.has_item(item_key, item_min, item_max)
			if has_item:
				branch = 0
			elif else_branch:
				branch = 1
			
		"Script":
			var res = global_si.execute_expr_from_data(menu_data)
			if res:
				branch = 0
			elif else_branch:
				branch = 1
	
	var branches = p_args["Branches"]
	if branches.has(branch):
		var branch_data = branches[branch]["Entries"]
		var instance = _instantiate_branch(branch, branch_data)
		_a_Branches.add_child(instance)
	else:
		_process_next_command(true)

func _process_teleport(p_data, p_args):
	var scene_manager_si = Global.get_singleton(self, "Scene_Manager")
	var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
	_a_tp_return_location = scene_manager_si.get_location()
	_a_tp_type = cutscene_system_si.get_option_value(p_data["Type"])
	match _a_tp_type:
		"Map":
			var instance = _instantiate_thread(p_data, _a_command)
			_a_Threads.add_child(instance)
		
		"Battle":
			set_persist(true)
			_a_tp_teleportation = cutscene_system_si.get_option_value(p_data["Teleportation"])
			_a_tp_handle_lost_battle = cutscene_system_si.get_option_value(p_data["Handle_Lost_Battle"])
			_a_tp_branches = p_args["Branches"]
			
			var battle_system_si = Global.get_singleton(self, "Battle_System")
			var battle_sv = battle_system_si.get_battle_sv()
			battle_sv.battle_ended.connect(_on_Battle_SV_battle_ended)
			battle_sv.battle(_a_tp_teleportation, BattleSV.MAP_RES.NEUTRAL)

func _process_match(p_data, p_args):
	# Execute condition and instance new branch
	var key = p_data["Key"]
	var menu_data = p_data["Menus"][key]
	var branches_values = menu_data["Branches_Values"]
	var branch = -1
	match key:
		"Choices":
			var progress_si = Global.get_singleton(self, "Progress")
			var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
			var key_type = cutscene_system_si.get_option_value(menu_data["Key_Type"])
			var chapter = cutscene_system_si.get_option_value(menu_data["Chapter"])
			var location = cutscene_system_si.get_option_value(menu_data["Location"])
			var dialogue_key = cutscene_system_si.get_option_value(menu_data["Dialogue"])
			var part_idx = cutscene_system_si.get_option_value(menu_data["Part"])
			var value = progress_si.get_dialogue_choice_value(key_type, chapter, location,
															  dialogue_key, part_idx)
			branch = branches_values.find(value) + 1
		
		"Script":
			var global_si = Global.get_singleton(self, "Global")
			var res = global_si.execute_expr_from_data(menu_data["Expression"])
			branch = branches_values.find(res) + 1
	
	var branches = p_args["Branches"]
	var branch_data = branches[branch]["Entries"]
	var branch_instance = _instantiate_branch(branch, branch_data)
	_a_Branches.add_child(branch_instance)

func _process_loop(p_data, p_args):
	var key = p_data["Key"]
	var args = p_data["Args"]
	match key:
		"For":
			var global_si = Global.get_singleton(self, "Global")
			var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
			var idx = cutscene_system_si.get_option_value(args["Idx"])
			_a_lf_step = cutscene_system_si.get_option_value(args["Step"])
			if _a_lf_iters == -1:
				var start = cutscene_system_si.get_option_value(args["Start"])
				var end = cutscene_system_si.get_option_value(args["End"])
				_a_lf_iters = int(floor(end - start) / _a_lf_step) + 1
				global_si.a_for_loop_idxs[idx] = start
			else:
				_a_l_first = false
				global_si.a_for_loop_idxs[idx] += _a_lf_step
			
			_a_lf_iters -= 1
	_a_l_key = key
	
	var branches = p_args["Branches"]
	var entries_data = branches[0]["Entries"]
	var instance = _instantiate_branch(0, entries_data)
	_a_Branches.add_child(instance)

func _process_sub_process(p_data, p_args):
	var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
	_a_id = cutscene_system_si.get_option_value(p_data["ID"])
	var branches = p_args["Branches"]
	var entries_data = branches[0]["Entries"]
	var instance = _instantiate_branch(0, entries_data)
	_a_Branches.add_child(instance)
	
	_process_next_command(true)

func _instantiate_branch(p_branch, p_data):
	var data_origin = _a_data_origin.duplicate()
	data_origin.push_back([_a_data_idx, p_branch])
	
	var instance = _a_Branch_Scene.instantiate()
	instance.command_changed.connect(_on_Branch_command_changed.bind(instance))
	instance.tree_exited.connect(_on_Branch_tree_exited)
	instance.completed.connect(_on_Branch_completed.bind(_a_command))
	instance.sub_process_completed.connect(_on_Branch_sub_process_completed)
	instance.request_exit.connect(_on_Branch_request_exit)
	instance.persist_changed.connect(_on_Branch_persist_changed)
	instance.set_thread_paths(_a_thread_paths)
	instance.set_curr_scene(_a_curr_scene)
	instance.set_process_type(_a_process_type)
	instance.set_key(_a_key)
	instance.set_entry_key(_a_entry_key)
	instance.set_key_type(_a_key_type)
	instance.set_caller(_a_caller)
	instance.set_data_origin(data_origin)
	instance.set_data(p_data)
	instance.set_process_mode(process_mode)
	
	var skip_idxs = _a_skip_idxs.duplicate()
	if !skip_idxs.is_empty():
		var curr_idx = skip_idxs[0]
		if _a_data_idx == curr_idx:
			skip_idxs.pop_front()
		else:
			skip_idxs.clear()
	
	match _a_command:
		"Loop":
			# Only skip in first loop iteration!
			if !_a_l_first && skip_idxs.size() == 1:
				instance.set_skip_idxs([])
				instance.set_skip(false)
			else:
				instance.set_skip_idxs(skip_idxs)
				instance.set_skip(_a_skip)
		_:
			instance.set_skip_idxs(skip_idxs)
			instance.set_skip(_a_skip)
	
	return instance

func _instantiate_thread(p_args, p_command, p_loads = false):
	var path = _a_thread_paths[p_command][_a_dim]
	var scene = load(path)
	var instance = scene.instantiate()
	instance.ready.connect(_on_Thread_ready.bind(instance))
	instance.tree_exited.connect(_on_Thread_tree_exited)
	instance.completed.connect(_on_Thread_completed)
	if p_command == "Exit_Cutscene":
		instance.request_exit.connect(_on_Thread_request_exit)
	instance.set_curr_scene(_a_curr_scene)
	instance.set_command(p_command)
	instance.set_skip(_a_skip)
	instance.set_process_mode(process_mode)
	
	if p_loads:
		instance.set_loads_data(true)
		instance.load_data.call_deferred(p_args)
	else:
		instance.set_args(p_args)
	
	return instance

func _sub_process_completed(p_id_ord):
	# Called when any child branch completes sub_process
	# -> Tell all threads and child branch threads
	handle_sub_process_threads(p_id_ord)
	for child in _a_Branches.get_children():
		child.handle_sub_process_threads(p_id_ord)
	sub_process_completed.emit(p_id_ord)

func _teleport_completed():
	set_persist(false)
	
	match _a_tp_type:
		"Battle":
			if _a_tp_branches.has(_a_tp_branch):
				var branch_data = _a_tp_branches[_a_tp_branch]["Entries"]
				var instance = _instantiate_branch(_a_tp_branch, branch_data)
				_a_Branches.add_child(instance)
			else:
				_process_next_command(true)

func _branches_loaded():
	_a_branches_loaded = true
	if _a_threads_loaded:
		data_loaded.emit()

func _threads_loaded():
	_a_threads_loaded = true
	if _a_branches_loaded:
		data_loaded.emit()

func set_thread_paths(p_thread_paths):
	_a_thread_paths = p_thread_paths

func set_curr_scene(p_curr_scene):
	_a_curr_scene = p_curr_scene

func get_command():
	return _a_command

func set_process_type(p_process_type):
	_a_process_type = p_process_type

func get_process_type():
	return _a_process_type

func set_key(p_key):
	_a_key = p_key

func get_key():
	return _a_key

func set_entry_key(p_entry_key):
	_a_entry_key = p_entry_key

func get_entry_key():
	return _a_entry_key

func set_key_type(p_key_type):
	_a_key_type = p_key_type

func set_caller(p_caller):
	_a_caller = p_caller

func get_caller():
	return _a_caller

func set_completed_cb(p_completed_cb):
	_a_completed_cb = p_completed_cb

func get_completed_cb():
	return _a_completed_cb

func set_skip_idxs(p_skip_idxs):
	_a_skip_idxs = p_skip_idxs

func set_skip(p_skip):
	_a_skip = p_skip

func set_data_origin(p_data_origin):
	_a_data_origin = p_data_origin

func set_data(p_data):
	_a_data = p_data

func has_completed():
	return _a_completed

func set_persist(p_persist):
	_a_persist = p_persist
	
	if p_persist:
		persist_changed.emit()
	else:
		for child in _a_Branches.get_children():
			child.set_persist(false)

func get_persist():
	return _a_persist

func set_loads_data(p_loads_data):
	_a_loads_data = p_loads_data

func set_process_mode_(p_process_mode):
	set_process_mode(p_process_mode)
	for child in _a_Branches.get_children():
		child.set_process_mode_(p_process_mode)
	for child in _a_Threads.get_children():
		child.set_process_mode(p_process_mode)

func get_save_data(p_for_file):
	var data = {}
	data["General"] = _get_general_save_data(p_for_file)
	data["Branches"] = _get_branches_save_data(p_for_file)
	data["Threads"] = _get_threads_save_data(p_for_file)
	
	return data

func _get_general_save_data(p_for_file):
	var data = {}
	data["Persist"] = _a_persist
	
	if p_for_file || !_a_persist:
		data["Command"] = _a_command
		data["Process_Type"] = _a_process_type
		data["Process_Mode"] = get_process_mode()
		data["Key"] = _a_key
		data["Entry_Key"] = _a_entry_key
		data["Key_Type"] = _a_key_type
		
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
		
		data["Data_Origin"] = _a_data_origin
		data["Data_Idx"] = _a_data_idx
		data["Completed"] = _a_completed
		
		data["Args"] = {}
		data["Args"]["Teleport"] = {}
		var tp_args = data["Args"]["Teleport"]
		tp_args["Type"] = _a_tp_type
		tp_args["Branches"] = _a_tp_branches
		tp_args["Teleportation"] = _a_tp_teleportation
		tp_args["Return_Location"] = _a_tp_return_location
		tp_args["Handle_Lost_Battle"] = _a_tp_handle_lost_battle
		tp_args["Branch"] = _a_tp_branch
		
		data["Args"]["Loop"] = {}
		var l_args = data["Args"]["Loop"]
		l_args["Key"] = _a_l_key
		l_args["For"] = {}
		l_args["For"]["Step"] = _a_lf_step
		l_args["For"]["Iters"] = _a_lf_iters
		
		data["Args"]["Sub_Process"] = {}
		var sp_args = data["Args"]["Sub_Process"]
		sp_args["ID"] = _a_id
	else:
		data["Self_Path"] = get_path()
	
	return data

func _get_branches_save_data(p_for_file):
	var data = []
	for child in _a_Branches.get_children():
		var save_data = child.get_save_data(p_for_file)
		data.push_back(save_data)
		
		if !p_for_file && !child.get_persist():
			child.queue_free()
	
	return data

func _get_threads_save_data(p_for_file):
	var data = []
	if p_for_file || !_a_persist:
		for child in _a_Threads.get_children():
			var save_data = child.get_save_data()
			data.push_back(save_data)
	
	return data

func load_data(p_data, p_for_file):
	_load_general_data.call_deferred(p_data["General"], p_for_file)
	_load_branches_data.call_deferred(p_data["Branches"], p_for_file)
	_load_threads_data.call_deferred(p_data["Threads"])

func _load_general_data(p_data, p_for_file):
	_a_persist = p_data["Persist"]
	if p_for_file || !_a_persist:
		var completed_cb_object_path = p_data["Completed_CB"]["Object_Path"]
		var completed_cb_object = get_node_or_null(completed_cb_object_path)
		if completed_cb_object != null:
			var completed_cb_name = p_data["Completed_CB"]["Name"]
			_a_completed_cb = Callable(completed_cb_object, completed_cb_name)
		
		_a_command = p_data["Command"]
		_a_process_type = p_data["Process_Type"]
		set_process_mode_.call_deferred(p_data["Process_Mode"])
		_a_data_origin = p_data["Data_Origin"]
		_a_data_idx = p_data["Data_Idx"]
		_a_completed = p_data["Completed"]
		
		var args = p_data["Args"]
		# Teleport
		_a_tp_type = args["Teleport"]["Type"]
		_a_tp_branches = args["Teleport"]["Branches"]
		_a_tp_teleportation = args["Teleport"]["Teleportation"]
		_a_tp_return_location = args["Teleport"]["Return_Location"]
		_a_tp_handle_lost_battle = args["Teleport"]["Handle_Lost_Battle"]
		_a_tp_branch = args["Teleport"]["Branch"]
		
		# Loop
		_a_l_key = args["Loop"]["Key"]
		# Loop_For
		_a_lf_step = args["Loop"]["For"]["Step"]
		_a_lf_iters = args["Loop"]["For"]["Iters"]
		
		# Sub_Process
		_a_id = args["Sub_Process"]["ID"]
		
		command_changed.emit()
		if _a_completed:
			completed.emit()

func _load_branches_data(p_data, p_for_file):
	for i in p_data.size():
		var args = p_data[i]
		
		var instance = null
		var persist = args["General"]["Persist"]
		if !p_for_file && persist:
			# The branch still exists
			var self_path = args["General"]["Self_Path"]
			instance = get_node(self_path)
		else:
			var data_origin = args["General"]["Data_Origin"]
			var cutscene_data = Databases.get_global_map_data("Cutscenes", _a_key_type, "", "", self)
			var data = cutscene_data[_a_key]["Data"][_a_entry_key]["Data"]["Default"].duplicate(true)
			for origin_args in data_origin:
				var idx = origin_args[0]
				var branch = origin_args[1]
				data = data[idx]
				data = data["Args"]["Branches"][branch]["Entries"]
			instance = _instantiate_branch(data_origin[-1][1], data)
		
		if i == p_data.size() - 1:
			instance.data_loaded.connect(_on_Branches_data_loaded)
		instance.set_loads_data(true)
		instance.load_data(args, p_for_file)
		
		if p_for_file || !persist:
			_a_Branches.add_child(instance)
	
	if p_data.is_empty():
		_branches_loaded()

func _load_threads_data(p_data):
	for i in p_data.size():
		var args = p_data[i]
		var command = args["Command"]
		var instance = _instantiate_thread(args, command, true)
		if i == p_data.size() - 1:
			instance.ready.connect(_on_Threads_data_loaded)
		_a_Threads.add_child(instance)
	
	if p_data.is_empty():
		_threads_loaded()

func _on_Branch_command_changed(p_instance):
	var command = p_instance.get_command()
	var idx = p_instance.get_index()
	p_instance.set_name("%s_%d" % [command, idx])

func _on_Branch_tree_exited():
	for child in _a_Branches.get_children():
		var command = child.get_command()
		var idx = child.get_index()
		child.set_name.call_deferred("%s_%d" % [command, idx])
	
	if _a_data_idx == _a_data.size():
		if _a_Branches.get_child_count() == 0:
			if _a_Threads.get_child_count() == 0:
				queue_free()

func _on_Branch_completed(p_command):
	match p_command:
		"Sub_Process":
			_sub_process_completed(_a_id)
		"Loop":
			match _a_l_key:
				"For":
					var inc = _a_lf_iters == 0
					_process_next_command(inc)
		_:
			_process_next_command(true)

func _on_Branch_sub_process_completed(p_id_ord):
	_sub_process_completed(p_id_ord)

func _on_Branch_request_exit():
	_a_completed = true
	request_exit.emit()

func _on_Branch_persist_changed():
	set_persist(true)

func _on_Branches_data_loaded():
	_branches_loaded()

func _on_Thread_ready(p_instance):
	var command = p_instance.get_command()
	var idx = p_instance.get_index()
	p_instance.set_name("%s_%d" % [command, idx])

func _on_Thread_tree_exited():
	for child in _a_Threads.get_children():
		var command = child.get_command()
		var idx = child.get_index()
		child.set_name("%s_%d" % [command, idx])
	
	if _a_data_idx == _a_data.size():
		if _a_Branches.get_child_count() == 0:
			if _a_Threads.get_child_count() == 0:
				queue_free()

func _on_Thread_completed():
	_process_next_command(true)

func _on_Thread_request_exit():
	_a_completed = true
	request_exit.emit()

func _on_Threads_data_loaded():
	_threads_loaded()

func _on_Battle_SV_battle_ended(p_location, p_res):
	if _a_tp_teleportation != p_location:
		return
	
	match p_res:
		"Win":
			_a_tp_branch = 1
		"Loss":
			if _a_tp_handle_lost_battle:
				_a_tp_branch = 2

func _on_Scene_Manager_scene_changed(p_instance, _p_loaded_file_data):
	set_curr_scene(p_instance)
	for child in _a_Threads.get_children():
		child.set_curr_scene(p_instance)
	
	if _a_command == "Teleport":
		var scene_manager_si = Global.get_singleton(self, "Scene_Manager")
		var location = scene_manager_si.get_location()
		if location == _a_tp_return_location:
			_teleport_completed()
