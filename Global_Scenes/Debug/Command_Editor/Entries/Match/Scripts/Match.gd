extends "res://Global_Scenes/Debug/Command_Editor/Entries/Scripts/Entry_Branch.gd"

var _a_Branch_Base_Scene = preload("res://Global_Scenes/Debug/Command_Editor/Entries/Branches/Base.tscn")

func swap_process_next():
	var child_amount = _a_Branches.get_child_count()
	var next_branch_idx = max(1, (_a_process_branch_idx + 1) % child_amount)
	swap_process(next_branch_idx)

# Breakable: Choices: ["Menus"]["Choices"]["Chapter"]["Value"] NOT IMPLEMENTED!!!
#					  ["Menus"]["Choices"]["Location"]["Value"] NOT IMPLEMENTED!!!
#					  ["Menus"]["Choices"]["Dialogue"]["Value"]
#					  ["Menus"]["Choices"]["Part"]["Value"]
#			 Script: ["Menus"]["Script"]["Expression"]["Instance_Key"]
func _update_warnings_add():
	var key = _a_data["Key"]
	var menu_data = _a_data["Menus"][key]
	match key:
		"Choices":
			var key_type = menu_data["Key_Type"]["Value"]
			var chapter = menu_data["Chapter"]["Value"]
			var location = menu_data["Location"]["Value"]
			var dialogue_key = menu_data["Dialogue"]["Value"]
			var dialogues_data = Databases.get_global_map_data("Dialogues", key_type, chapter, location)
			if dialogues_data.has(dialogue_key):
				var part_idx = menu_data["Part"]["Value"]
				var parts_data = dialogues_data[dialogue_key]["Data"]
				if !parts_data.has(str(part_idx)):
					var value_keys = ["Menus", "Choices", "Part", "Value"]
					var max_ = parts_data.size() - 1
					var args = _Warning_Args_Int.new(part_idx, value_keys, 0, max_)
					_a_warnings.push_back(args)
			else:
				var value_keys = ["Menus", "Choices", "Dialogue", "Value"]
				var args = _Warning_Args_String.new(dialogue_key, value_keys)
				_a_warnings.push_back(args)
		
		"Script":
			var value_keys = ["Menus", "Script", "Expression", "Instance_Key"]
			var expression_args = menu_data["Expression"]
			_update_warnings_add_expression(expression_args, value_keys)

func _update_display_main_base_args():
	var key = _a_data["Key"]
	var menu_data = _a_data["Menus"][key]
	
	var text = ""
	match key:
		"Choices":
			var dialogue_key = _get_display_text(menu_data["Dialogue"])
			var part_idx = _get_display_text(menu_data["Part"])
			text = "%s: " % tr("CHOICES")
			text += dialogue_key
			text += ", %s: " % tr("DEBUG_PART")
			text += part_idx
		
		"Script":
			var instance_key = menu_data["Expression"]["Instance_Key"]
			var expression = menu_data["Expression"]["Expression"]
			text = "%s: " % tr("DEBUG_CUTSCENES_SCRIPT")
			text += instance_key
			text += ": %s" % expression
	_a_Main.set_base_args(text)

func _delete_branches(p_from):
	for i in range(p_from, _a_Branches.get_child_count()):
		var child = _a_Branches.get_child(i)
		child.queue_free()

func _instantiate_branches(p_values, p_from):
	var base_min_size = _a_Main.get_base_margin_min_size()
	var margin = _get_main_arg_margin()
	for i in range(p_from, p_values.size()):
		var branch_name = str(p_values[i])
		var margin_min_size = Vector2(margin, base_min_size.y)
		_instantiate_branch(branch_name, margin_min_size)

func _instantiate_branch(p_branch_name, p_margin_min_size):
	var instance = _a_Branch_Base_Scene.instantiate()
	instance.base_focus_entered.connect(_on_Unselectable_focus_entered)
	instance.base_gui_input.connect(_on_Unselectable_gui_input)
	instance.progress_focus_entered.connect(_on_Unselectable_focus_entered)
	instance.progress_gui_input.connect(_on_Unselectable_gui_input)
	instance.set_base_desc.call_deferred(p_branch_name)
	instance.set_base_desc_modulate.call_deferred(_e_color)
	instance.set_base_margin_min_size.call_deferred(p_margin_min_size)
	
	_a_Branches.add_child(instance)

func _init_branches():
	var key = _a_data["Key"]
	var branches_values = _a_data["Menus"][key]["Branches_Values"]
	_instantiate_branches(branches_values, 0)
	
	# Frame needed for branches to be ready
	await get_tree().process_frame
	super()

func _update_branches():
	var key = _a_data["Key"]
	var branches_values = _a_data["Menus"][key]["Branches_Values"]
	var child_count = _a_Branches.get_child_count()
	var branches_amount = branches_values.size()
	var to = child_count - 1
	if to > branches_amount:
		var from = branches_amount + 1
		_delete_branches(from)
		to = branches_amount
	
	for i in to:
		var branch_name = str(branches_values[i])
		var child = _a_Branches.get_child(i + 1)
		child.set_base_desc(branch_name)
	_instantiate_branches(branches_values, to)
	
	# Frame needed for old branches to be freed and new branches to be ready
	await get_tree().process_frame
	
	var margin = _get_main_arg_margin()
	for i in range(to + 1, branches_amount + 1):
		var child = _a_Branches.get_child(i)
		var entries = child.get_entries_instance()
		request_empty_entry.emit(i, margin, entries)
	
	_a_process_branch_idx = min(_a_process_branch_idx, branches_amount)
	swap_process(_a_process_branch_idx)
	
	for i in range(1, _a_Branches.get_child_count()):
		var child = _a_Branches.get_child(i)
		var process_margin = child.get_process_margin_instance()
		process_margin.custom_minimum_size.x = margin
		child.set_collapse_visible(true)
	_a_End.set_left_margin(margin)

func set_args(p_args):
	super(p_args)
	if !_a_args.has("Process_Branch_Idx"):
		_a_args["Process_Branch_Idx"] = 1
