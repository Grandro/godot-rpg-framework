extends "res://Scripts/Extension_Base.gd"

signal interacted()
signal interaction_activated(p_area)
signal interaction_deactivated()

var _a_Default_Interaction = null

var _a_entity_entity = null

var _a_interaction_allowed = true

func init(p_entity_entity):
	_a_entity_entity = p_entity_entity
	
	p_entity_entity.visibility_changed.connect(_on_Entity_Entity_visibility_changed)

func ready():
	_a_Default_Interaction = _a_entity.get_node("1")

func interaction(p_area):
	var cutscene_args = p_area.get_cutscene_args()
	if !cutscene_args.is_empty():
		_interaction_cutscene(p_area, cutscene_args)
	else:
		var dialogue_args = p_area.get_dialogue_args()
		if !dialogue_args.is_empty():
			_interaction_dialogue(p_area, dialogue_args)
	
	p_area.increase_interaction_count()
	interacted.emit()

func interaction_activate(p_area, _p_dir):
	var popup_type = p_area.get_popup_type()
	if popup_type != "None":
		p_area.set_active(true)
		interaction_activated.emit(p_area)

func interaction_deactivate(p_area):
	var popup_type = p_area.get_popup_type()
	if popup_type != "None":
		p_area.set_active(false)
		interaction_deactivated.emit()

func increase_interaction_cutscene_args_idx(p_idx, p_value):
	var instance = _a_entity.get_child(p_idx)
	instance.increase_cutscene_args_idx(p_value)

func increase_interaction_dialogue_args_idx(p_idx, p_value):
	var instance = _a_entity.get_child(p_idx)
	instance.increase_dialogue_args_idx(p_value)

func _interaction_cutscene(p_area, p_args):
	var cutscene_system_si = Global.get_singleton(_a_entity, "Cutscene_System")
	var process_type = p_area.get_cutscene_process_type()
	var key_type = p_area.get_cutscene_key_type()
	var args_idx = p_area.get_cutscene_args_idx()
	var args = p_args[args_idx]
	var key = args[0]
	var entry_key = args[1]
	cutscene_system_si.cutscene(key, entry_key, process_type, key_type)
	cutscene_system_si.set_cutscene_completed_cb(key, entry_key, _a_entity.CB_cutscene_completed)
	cutscene_system_si.set_cutscene_caller(key, entry_key, _a_entity_entity)

func _interaction_dialogue(p_area, p_args):
	var dialogue_system_si = Global.get_singleton(_a_entity, "Dialogue_System")
	var process_type = p_area.get_dialogue_process_type()
	var fade_out = p_area.get_dialogue_fade_out()
	var start_idx = p_area.get_dialogue_start_idx()
	var end_idx = p_area.get_dialogue_end_idx()
	var key_type = p_area.get_dialogue_key_type()
	var args_idx = p_area.get_dialogue_args_idx()
	var key = p_args[args_idx]
	dialogue_system_si.dialogue(key, _a_entity_entity, process_type, fade_out,
								start_idx, end_idx, key_type)
	dialogue_system_si.set_dialogue_layer(key, 10)
	dialogue_system_si.set_dialogue_completed_cb(key, _a_entity.CB_dialogue_completed)
	dialogue_system_si.set_dialogue_choice_selected_cb(key, _a_entity.CB_dialogue_choice_selected)

func set_interaction_cutscene_args_idx(p_idx, p_args_idx):
	var instance = _a_entity.get_child(p_idx)
	instance.set_cutscene_args_idx(p_args_idx)

func set_interaction_dialogue_args_idx(p_idx, p_args_idx):
	var instance = _a_entity.get_child(p_idx)
	instance.set_dialogue_args_idx(p_args_idx)

func set_interaction_allowed(p_interaction_allowed):
	_a_interaction_allowed = p_interaction_allowed

func get_interaction_allowed():
	return _a_interaction_allowed

func set_interaction_cutscene_args(p_idx, p_args):
	var instance = _a_entity.get_child(p_idx)
	instance.set_cutscene_args(p_args)

func set_interaction_dialogue_args(p_idx, p_args):
	var instance = _a_entity.get_child(p_idx)
	instance.set_dialogue_args(p_args)

func get_default_interaction_pos():
	return _a_Default_Interaction.get_global_position()

func get_interaction_count(p_idx):
	var instance = _a_entity.get_child(p_idx)
	var interaction_count = instance.get_interaction_count()
	
	return interaction_count

func get_entity_entity():
	return _a_entity_entity

func get_save_data():
	var data = {}
	data["Interactions"] = []
	for child in _a_entity.get_children():
		var args = {}
		args["Type"] = child.get_type()
		args["Dirs"] = child.get_dirs()
		args["Match_Dir"] = child.get_match_dir()
		args["Popup_Type"] = child.get_popup_type()
		args["Cutscene_Args"] = child.get_cutscene_args()
		args["Cutscene_Args_Idx"] = child.get_cutscene_args_idx()
		args["Dialogue_Args"] = child.get_dialogue_args()
		args["Dialogue_Args_Idx"] = child.get_dialogue_args_idx()
		args["Interaction_Count"] = child.get_interaction_count()
		
		data["Interactions"].push_back(args)
	
	data["Interaction"] = {}
	data["Interaction"]["Allowed"] = get_interaction_allowed()
	
	return data

func load_data(p_data):
	for i in _a_entity.get_child_count():
		var child = _a_entity.get_child(i)
		var args = p_data["Interactions"][i]
		child.set_type(args["Type"])
		child.set_dirs(args["Dirs"])
		child.set_match_dir(args["Match_Dir"])
		child.set_popup_type(args["Popup_Type"])
		child.set_cutscene_args(args["Cutscene_Args"])
		child.set_cutscene_args_idx(args["Cutscene_Args_Idx"])
		child.set_dialogue_args(args["Dialogue_Args"])
		child.set_dialogue_args_idx(args["Dialogue_Args_Idx"])
		child.set_interaction_count(args["Interaction_Count"])
	
	_a_interaction_allowed = p_data["Interaction"]["Allowed"]

func CB_cutscene_completed(_p_type, _p_key, _p_entry_key):
	pass

func CB_dialogue_completed(_p_key):
	pass

func CB_dialogue_choice_selected(_p_key, _p_value):
	pass

func _on_Entity_Entity_visibility_changed():
	var is_visible = _a_entity_entity.is_visible()
	for child in _a_entity.get_children():
		child.set_monitorable(is_visible)
