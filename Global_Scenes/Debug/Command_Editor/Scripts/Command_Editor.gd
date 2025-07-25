extends HBoxContainer

signal option_test_selected(p_instance)
signal selectable_focus_entered()

@export var _e_edit_scene_paths : Dictionary = {} # [Command][Dim] = path

var _a_Entry_Base_Scene = preload("res://Global_Scenes/Debug/Command_Editor/Entries/Entry_Base.tscn")

const _a_ENTRY_PATH = "res://Global_Scenes/Debug/Command_Editor/Entries/%s/%s.tscn"

@onready var _a_Entries = get_node("Contents/Panel/Entries")
@onready var _a_Options = get_node("Contents/Panel/Options")
@onready var _a_Warnings = get_node("Contents/Panel/Warnings")

var _a_active = false # Is currently active?
var _a_new_option = false # Commands_List openend to create a new entry?
var _a_selected = [] # Selected entries 
var _a_first = null # First selected entry
var _a_last_focused = null # Last focused entry
var _a_test_entry = null # Entry with test mark

func _ready():
	_a_Options.option_selected.connect(_on_Options_option_selected)
	Debug.closing.connect(_on_Debug_closing)
	
	set_process_unhandled_input(false)

func _unhandled_input(p_event):
	if _a_Options.is_visible():
		return
	
	if p_event.is_action_pressed("Space"):
		_option_edit()
	elif p_event.is_action_pressed("Cut"):
		_option_cut()
	elif p_event.is_action_pressed("Copy"):
		_option_copy()
	elif p_event.is_action_pressed("Paste"):
		_option_paste()
	elif p_event.is_action_pressed("Delete"):
		_option_delete()
	elif p_event.is_action_pressed("Select_All"):
		_option_select_all()
	elif p_event.is_action_pressed("Test"):
		_option_test()
	elif p_event.is_action_pressed("Swap_Process"):
		_option_swap_process()
	elif p_event.is_action_pressed("Shift_Up"):
		_shift_arrows(-1)
	elif p_event.is_action_pressed("Shift_Down"):
		_shift_arrows(1)

func update_entries(p_data):
	clear_entries()
	
	var last = _instantiate_empty_entry()
	_a_Entries.add_child(last)
	
	for data in p_data:
		var command = data["Command"]
		var entry_data = data["Data"].duplicate(true)
		var entry_args = data["Args"].duplicate(true)
		_instantiate_command_entry_add(command, entry_data, entry_args)

func clear_entries():
	clear_selected()
	for child in _a_Entries.get_children():
		child.queue_free()

func clear_selected():
	for selected in _a_selected:
		selected.set_fake_focus(false)
		selected.release_main_base_focus()
	_a_selected.clear()

func disable_last_entry():
	var last = _a_Entries.get_child(-1)
	last.disable()

func _instantiate_empty_entry():
	var instance = _a_Entry_Base_Scene.instantiate()
	instance.connect_to_editor(self)
	
	return instance

func _instantiate_command_entry(p_command, p_data, p_args = {}, p_margin = 4):
	var path = _a_ENTRY_PATH % [p_command, p_command]
	var scene = load(path)
	var instance = scene.instantiate()
	instance.connect_to_editor(self)
	instance.set_command(p_command)
	instance.set_branches_margin.call_deferred(p_margin)
	instance.set_args.call_deferred(p_args)
	instance.update_data.call_deferred(p_data)
	
	return instance

func _instantiate_command_entry_add(p_command, p_data, p_args):
	var instance = _instantiate_command_entry(p_command, p_data, p_args)
	var child_count = _a_Entries.get_child_count()
	_a_Entries.add_child(instance)
	_a_Entries.move_child(instance, child_count - 1)

func _add_for_loop_idx_ords(p_res_data):
	var idx_ords = _get_for_loop_idx_ords(_a_first)
	p_res_data["Misc"]["For_Loop_Idx_Ords"] = idx_ords

func _add_sub_process_id_ords(p_res_data):
	var id_ords = _get_sub_process_id_ords(_a_first)
	p_res_data["Misc"]["Sub_Process_ID_Ords"] = id_ords

func _option_new():
	_a_new_option = true
	var commands_list = Debug.get_commands_list()
	commands_list.open()

func _option_edit():
	if _a_first.is_empty():
		return
	
	var command = _a_first.get_command()
	var res_data = _get_combined_entry_res_data(_a_first)
	match command:
		"Loop": _add_for_loop_idx_ords(res_data)
		"Sub_Process": _add_sub_process_id_ords(res_data)
	
	var dim = Scene_Manager.get_curr_scene_dim()
	var path = _e_edit_scene_paths[command][dim]
	var data = _a_first.get_data()
	var command_edit = Debug.get_command_edit()
	command_edit.open(_a_first, command, path, data, res_data)

func _option_cut():
	var to_copy = _get_selected_copyable()
	if to_copy.is_empty():
		return
	
	var first_idx = _a_first.get_index()
	var last = to_copy.back()
	var last_idx = last.get_index()
	var next_idx = max(first_idx, last_idx) + 1
	
	var clipboard = []
	for instance in to_copy:
		var command = instance.get_command()
		var data = instance.get_editor_data()
		var args = [command, data]
		clipboard.push_back(args)
		
		instance.queue_free()
	Debug.set_command_editor_clipboard(clipboard)
	
	var parent = _get_nearest_parent(_a_first)
	var branch_idx = _a_first.get_branch_idx()
	var entry_count = -1
	if parent == _a_Entries:
		entry_count = parent.get_child_count()
	else:
		entry_count = parent.get_entries_count(branch_idx)
	
	if entry_count > next_idx:
		var next_focus = null
		if parent == _a_Entries:
			next_focus = parent.get_child(next_idx)
		else:
			next_focus = parent.get_branch_entry(branch_idx, next_idx)
		next_focus.grab_main_base_focus()
		
		_a_selected = [next_focus]
		_a_first = next_focus
	
	_a_Options.set_option_disabled("Paste", false)

func _option_copy():
	var to_copy = _get_selected_copyable()
	if to_copy.is_empty():
		return
	
	var clipboard = []
	for instance in to_copy:
		var command = instance.get_command()
		var data = instance.get_editor_data()
		var args = [command, data]
		clipboard.push_back(args)
	Debug.set_command_editor_clipboard(clipboard)
	
	_a_Options.set_option_disabled("Paste", false)

func _option_paste():
	var clipboard = Debug.get_command_editor_clipboard()
	if clipboard.is_empty():
		return
	
	var parents = _a_first.get_parents().duplicate()
	var branch_idx = _a_first.get_branch_idx()
	var margin = _a_first.get_branches_margin()
	var parent = _a_first.get_parent()
	var focused_idx = _a_first.get_index()
	var size_ = clipboard.size()
	for i in size_:
		var idx = size_ - 1 - i
		var args = clipboard[idx]
		var command = args[0]
		var data = args[1]
		var command_data = data["Data"]
		var command_args = data["Args"]
		
		var instance = _instantiate_command_entry(command, command_data, command_args, margin)
		instance.set_parents(parents)
		instance.set_branch_idx(branch_idx)
		
		parent.add_child(instance)
		parent.move_child(instance, focused_idx)

func _option_delete():
	var selected = _get_selected_copyable()
	if selected.is_empty():
		return
	
	var first_idx = _a_first.get_index()
	var last = selected.back()
	var last_idx = last.get_index()
	var next_idx = max(first_idx, last_idx) + 1
	
	for instance in selected:
		instance.queue_free()
	
	var parent = _get_nearest_parent(_a_first)
	var branch_idx = _a_first.get_branch_idx()
	var entry_count = -1
	if parent == _a_Entries:
		entry_count = parent.get_child_count()
	else:
		entry_count = parent.get_entries_count(branch_idx)
	
	var next_focus = null
	if entry_count > next_idx:
		if parent == _a_Entries:
			next_focus = parent.get_child(next_idx)
		else:
			next_focus = parent.get_branch_entry(branch_idx, next_idx)
	else:
		if parent == _a_Entries:
			var child_count = parent.get_child_count()
			next_focus = parent.get_child(child_count - 1)
		else:
			var child_count = parent.get_entries_count(branch_idx)
			next_focus = parent.get_branch_entry(branch_idx, child_count - 1)
	
	next_focus.grab_main_base_focus()
	
	_a_selected = [next_focus]
	_a_first = next_focus

func _option_select_all():
	_a_selected.clear()
	_a_first = null
	
	var children = _a_Entries.get_children()
	for i in children.size() - 1:
		var child = children[i]
		if i == 0:
			child.grab_main_base_focus()
			_a_first = child
		
		child.set_fake_focus(true)
		_a_selected.push_back(child)

func _option_test():
	option_test_selected.emit(_a_first)

func _option_swap_process():
	var branches_idxs = _a_first.get_used_branches_idxs()
	if branches_idxs.size() <= 1:
		return
	
	_a_first.swap_process_next()

func _option_change_mark(p_mark):
	_a_first.set_mark(p_mark)

func _shift_logic(p_clicked):
	if _a_selected.is_empty():
		_a_selected = [p_clicked]
		_a_first = p_clicked
		_a_last_focused = p_clicked
		return
	
	# Release focus and clear selected entries
	clear_selected()
	
	var focused_parents = _a_first.get_parents()
	var clicked_parents = p_clicked.get_parents()
	var sel_entry = null
	var nosel_entry = null
	
	# Get nearest parent (We focus the children of that)
	# Get Sel Entry (The Entry which selectes the nearest parent)
	# Get NoSel Entry (The Entry which didnt't select the nearest parent)
	var nearest_parent = null
	if focused_parents.size() < clicked_parents.size():
		nearest_parent = _get_nearest_parent(_a_first)
		sel_entry = _a_first
		nosel_entry = p_clicked
	else:
		nearest_parent = _get_nearest_parent(p_clicked)
		sel_entry = p_clicked
		nosel_entry = _a_first
	
	# Get instance which is a parent of lo_entry and a child of nearest parent
	var sel_idx = sel_entry.get_index()
	var nosel_idx = 0
	
	var children = []
	if nearest_parent == _a_Entries:
		children = nearest_parent.get_children()
	else:
		children = nearest_parent.get_entries()
	
	for child in children:
		if child.is_ancestor_of(nosel_entry) || child == nosel_entry:
			nosel_idx = child.get_index()
			break
	
	# Set start and end idx
	var start_idx = min(sel_idx, nosel_idx)
	var end_idx = max(sel_idx, nosel_idx)
	
	var focused_idx = nosel_idx
	var clicked_idx = sel_idx
	if _a_first == sel_entry:
		focused_idx = sel_idx
		clicked_idx = nosel_idx
	
	# Shift start idx in special cases
	var sel_parents = sel_entry.get_parents()
	var nosel_parents = nosel_entry.get_parents()
	if sel_parents.size() > 0 || nosel_parents.size() > 0:
		if focused_parents.size() < clicked_parents.size():
			if clicked_idx < focused_idx:
				start_idx += 1
		
		if focused_parents.size() > clicked_parents.size():
			if clicked_idx > focused_idx:
				start_idx += 1
	
	# If instances are not in same branch only clicked should be selected
	if !is_entries_in_same_branch(_a_first, p_clicked):
		_a_selected = [p_clicked]
		_a_first = p_clicked
		_a_last_focused = p_clicked
		return
	
	var branch_idx = sel_entry.get_branch_idx()
	
	# Focus the entries
	for i in range(start_idx, end_idx + 1):
		var entry = null
		if nearest_parent == _a_Entries:
			entry = nearest_parent.get_child(i)
		else:
			entry = nearest_parent.get_branch_entry(branch_idx, i)
		
		entry.set_fake_focus(true)
		_a_selected.push_back(entry)
	
	if !_a_selected.has(_a_first):
		if focused_parents.size() > 0:
			var next_parent = focused_parents[-1]
			if _a_selected.has(next_parent):
				_a_first.set_fake_focus(true)
				_a_selected.push_back(_a_first)
	
	_a_last_focused = p_clicked

func _shift_arrows(p_shift):
	var next_focus = _a_last_focused
	var parents = _a_last_focused.get_parents()
	var last_focused_idx = _a_last_focused.get_index()
	var shifted_idx = last_focused_idx + p_shift
	var entry_parent = _a_Entries
	var branch_idxs = _a_last_focused.get_branch_idxs()
	var branch_idx = -1
	for i in parents.size():
		var idx = parents.size() - i - 1
		branch_idx = branch_idxs[branch_idxs.size() - i - 1]
		
		var parent = parents[idx]
		var entry_count = parent.get_entries_count(branch_idx)
		
		if shifted_idx >= 0:
			if entry_count > shifted_idx:
				entry_parent = parent
				break
		
		var parent_idx = parent.get_index()
		if p_shift == -1:
			shifted_idx = parent_idx
		else:
			shifted_idx = parent_idx + p_shift
	
	if entry_parent == _a_Entries:
		if shifted_idx >= 0:
			if _a_Entries.get_child_count() > shifted_idx:
				next_focus = _a_Entries.get_child(shifted_idx)
	else:
		next_focus = entry_parent.get_branch_entry(branch_idx, shifted_idx)
	
	_shift_logic(next_focus)
	next_focus.grab_main_base_focus()

func is_entries_in_same_branch(p_focused, p_clicked):
	var bigger_idxs = []
	var other_idxs = []
	var focused_idxs = p_focused.get_branch_idxs()
	var clicked_idxs = p_clicked.get_branch_idxs()
	
	if focused_idxs.size() > clicked_idxs.size():
		bigger_idxs = focused_idxs
		other_idxs = clicked_idxs
	else:
		bigger_idxs = clicked_idxs
		other_idxs = focused_idxs
	
	for i in other_idxs.size():
		var other_idx = other_idxs[i]
		var biggest_idx = bigger_idxs[i]
		if biggest_idx != other_idx:
			return false
	
	return true

func _get_combined_entry_res_data(p_instance):
	# 1) If p_instance == nested entry, p_instance should be the root parent
	#    end_idx should be one higher and if child == root parent
	#    should deliver res_data till the original p_instance is reached
	# -> root parent collects res_data of all its children (depending on which branch
	#    is chosen (depending on p_instance _a_branch_idx/ root parent _a_process_branch_idx))
	
	var root = p_instance
	var org_idx = p_instance.get_index()
	var end_idx = org_idx
	var parents = p_instance.get_parents()
	if parents.size() > 0:
		# Nested entry
		root = parents[0]
		end_idx = root.get_index() + 1
	
	var res_data = _get_empty_res_data()
	for i in end_idx:
		var child = _a_Entries.get_child(i)
		if child == root:
			var branch_idx = p_instance.get_branch_idx()
			var args = [branch_idx, org_idx]
			child.add_res_data(res_data, args)
		else:
			child.add_res_data(res_data)
	
	return res_data

func _get_empty_res_data():
	var data = {}
	data["Misc"] = {}
	data["Misc"]["For_Loop_Idx_Ords"] = []
	data["Misc"]["Sub_Process_ID_Ords"] = []
	data["Objects"] = {}
	data["Default_Object"] = ""
	data["$Free_Camera"] = {}
	data["$Free_Camera"]["Object"] = ""
	
	return data

func _get_selected_real():
	# First entry in a_selected could be nested too deep
	var entries = []
	for entry in _a_selected:
		if entry == _a_first:
			if _a_selected.size() > 1:
				var second = _a_selected[1]
				var first_parents = _a_first.get_parents()
				var second_parents = second.get_parents()
				if first_parents.size() > second_parents.size():
					continue
		
		entries.push_back(entry)
	
	return entries

func _get_selected_copyable():
	# Command of entry could be empty
	var entries = []
	var real_entries = _get_selected_real()
	for entry in real_entries:
		if !entry.is_empty():
			entries.push_back(entry)
	
	return entries

func _get_nearest_parent(p_entry):
	var nearest = _a_Entries
	var parents = p_entry.get_parents()
	if parents.size() > 0:
		nearest = parents[-1]
	
	return nearest

func _get_for_loop_idx_ords(p_instance):
	var idx_ords = []
	var parents = p_instance.get_parents()
	for parent in parents:
		var command = parent.get_command()
		if command == "Loop":
			var data = parent.get_data()
			var key = data["Key"]
			if key == "For":
				var idx_ord = int(data["Args"]["Idx_Ord"])
				idx_ords.push_back(idx_ord)
	
	return idx_ords

func _get_sub_process_id_ords(p_instance):
	var id_ords = []
	var parents = p_instance.get_parents()
	for parent in parents:
		var command = parent.get_command()
		if command == "Sub_Process":
			var data = parent.get_data()
			var id_ord = int(data["ID"]["Value"])
			id_ords.push_back(id_ord)
	
	return id_ords

func get_skip_idxs(p_instance = null):
	if p_instance == null:
		if _a_test_entry == null:
			p_instance = _a_Entries.get_child(0)
		else:
			p_instance = _a_test_entry
	
	var parents = p_instance.get_parents()
	var idxs = []
	for parent in parents:
		var parent_idx = parent.get_index()
		idxs.push_back(parent_idx)
	var idx = p_instance.get_index()
	idxs.push_back(idx)
	
	return idxs

func set_active(p_active):
	if _a_active == p_active:
		return
	
	var commands_list = Debug.get_commands_list()
	var command_edit = Debug.get_command_edit()
	if p_active:
		commands_list.command_selected.connect(_on_Commands_List_command_selected)
		commands_list.closed.connect(_on_Commands_List_closed)
		command_edit.command_ok.connect(_on_Command_Edit_command_ok)
	else:
		commands_list.command_selected.disconnect(_on_Commands_List_command_selected)
		commands_list.closed.disconnect(_on_Commands_List_closed)
		command_edit.command_ok.disconnect(_on_Command_Edit_command_ok)
	
	set_process_unhandled_input(p_active)
	_a_active = p_active

func get_cutscene_data():
	var cutscene_data = []
	for child in _a_Entries.get_children():
		if child.is_empty():
			continue
		
		var data = child.get_cutscene_data()
		if typeof(data) == TYPE_ARRAY:
			for args in data:
				cutscene_data.push_back(args)
		else:
			cutscene_data.push_back(data)
	
	return cutscene_data

func get_save_data():
	var data = []
	for child in _a_Entries.get_children():
		if !child.is_empty():
			var entry_data = child.get_save_data()
			data.push_back(entry_data)
	
	return data

func _on_Commands_List_command_selected(p_command):
	var res_data = _get_combined_entry_res_data(_a_first)
	match p_command:
		"Loop": _add_for_loop_idx_ords(res_data)
		"Sub_Process": _add_sub_process_id_ords(res_data)
	
	var dim = Scene_Manager.get_curr_scene_dim()
	var path = _e_edit_scene_paths[p_command][dim]
	var command_edit = Debug.get_command_edit()
	if _a_new_option:
		command_edit.open(_a_first, p_command, path, {}, res_data)
	else:
		var data = _a_first.get_data()
		command_edit.open(_a_first, p_command, path, data, res_data)

func _on_Commands_List_closed():
	_a_new_option = false

func _on_Command_Edit_command_ok(p_data, p_command):
	if _a_new_option:
		var margin = _a_first.get_branches_margin()
		var parent = _a_first.get_parent()
		var instance = _instantiate_command_entry(p_command, p_data, {}, margin)
		var parents = _a_first.get_parents().duplicate()
		var branch_idx = _a_first.get_branch_idx()
		instance.set_parents(parents)
		instance.set_branch_idx(branch_idx)
		
		var idx = _a_first.get_index()
		parent.add_child(instance)
		parent.move_child(instance, idx)
	else:
		_a_first.update_data(p_data)
	
	_a_first.grab_main_base_focus()
	
	var commands_list = Debug.get_commands_list()
	commands_list.close()

func _on_Options_option_selected(p_option):
	match p_option:
		"New": _option_new()
		"Edit": _option_edit()
		"Cut": _option_cut()
		"Copy": _option_copy()
		"Paste": _option_paste()
		"Delete": _option_delete()
		"Select_All": _option_select_all()
		"Test": _option_test()
		"Swap_Process": _option_swap_process()
		"Change_Mark_Default": _option_change_mark("Default")
		"Change_Mark_Test": _option_change_mark("Test")

func _on_Debug_closing():
	_a_Options.close()

func _on_Entry_activated():
	_option_new()

func _on_Entry_selectable_focus_entered(p_instance):
	if !Input.is_action_pressed("Shift"):
		for instance in _a_selected:
			if instance != p_instance:
				instance.set_fake_focus(false)
				instance.release_main_base_focus()
		p_instance.set_fake_focus(true)
		
		_a_selected = [p_instance]
		_a_first = p_instance
	
	_a_last_focused = p_instance
	
	selectable_focus_entered.emit()

func _on_Entry_selectable_left_clicked(p_instance):
	if Input.is_action_pressed("Shift"):
		_shift_logic(p_instance)

func _on_Entry_selectable_right_clicked(p_pos, p_instance):
	if p_instance.is_empty():
		var options = ["Change_Mark", "Copy", "Cut", "Delete", "Edit", "Test"]
		for option in options:
			_a_Options.set_option_disabled(option, true)
	else:
		_a_Options.set_options_disabled_all(false, ["Paste"])
	
	p_instance.set_fake_focus(true)
	if !_a_selected.has(p_instance):
		for instance in _a_selected:
			instance.set_fake_focus(false)
			instance.release_main_base_focus()
		
		_a_selected = [p_instance]
	_a_first = p_instance
	
	var branches_idxs = p_instance.get_used_branches_idxs()
	var show_swap_process = branches_idxs.size() > 1
	_a_Options.set_option_visible("Swap_Process", show_swap_process)
	_a_Options.open(p_pos)

func _on_Entry_arg_focus_entered(p_instance):
	if Input.is_action_pressed("Shift"):
		_shift_logic(p_instance)
	else:
		for instance in _a_selected:
			instance.release_main_base_focus()
			instance.set_fake_focus(false)
		
		_a_selected.clear()
		_a_first = p_instance

func _on_Entry_arg_right_clicked(p_pos, p_instance):
	if _a_selected.has(p_instance):
		_a_Options.set_options_disabled_all(false)
		p_instance.set_fake_focus(true)
	else:
		for instance in _a_selected:
			instance.release_main_base_focus()
			instance.set_fake_focus(false)
		
		_a_selected.clear()
		_a_first = p_instance
		_a_Options.set_options_disabled(["Select_All"], false, true)
	
	_a_Options.set_option_visible("Swap_Process", false)
	_a_Options.open(p_pos)

func _on_Entry_warning_pressed(p_pos, p_instance):
	_a_Warnings.open(p_pos, p_instance)

func _on_Entry_mark_changed(p_mark, p_instance):
	match p_mark:
		"Default":
			if _a_test_entry == p_instance:
				_a_test_entry = null
		"Test":
			if is_instance_valid(_a_test_entry):
				_a_test_entry.set_mark("Default")
			_a_test_entry = p_instance

func _on_Entry_unselectable_focus_entered():
	clear_selected()

func _on_Entry_unselectable_right_clicked(p_pos):
	clear_selected()
	
	_a_Options.set_options_disabled(["Select_All"], false, true)
	_a_Options.set_option_visible("Swap_Process", false)
	_a_Options.open(p_pos)

func _on_Entry_request_empty_entry(p_branch_idx, p_margin, p_entries, p_entry):
	var instance = _instantiate_empty_entry()
	var parents = p_entry.get_parents().duplicate()
	parents.push_back(p_entry)
	instance.set_parents(parents)
	instance.set_branch_idx(p_branch_idx)
	instance.set_branches_margin.call_deferred(p_margin)
	p_entries.add_child(instance)

func _on_Entry_request_command_entry(p_command, p_data, p_branch_idx, p_margin, p_entries, p_entry):
	var instance = _instantiate_command_entry(p_command, p_data["Data"], p_data["Args"], p_margin)
	var parents = p_entry.get_parents().duplicate()
	parents.push_back(p_entry)
	instance.set_parents(parents)
	instance.set_branch_idx(p_branch_idx)
	p_entries.add_child(instance)
