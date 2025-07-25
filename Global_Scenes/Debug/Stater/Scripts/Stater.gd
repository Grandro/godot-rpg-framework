extends "res://Global_Scenes/Debug/Keys_Editor/Scripts/Keys_Editor_Parts.gd"

@onready var _a_Attributes = get_node("VBox/HBox/VBox/Panel/Scroll/Attributes")

func _ready():
	super()
	_a_Parts.entry_type_changed.connect(_on_Parts_entry_type_changed)
	_a_Parts.entry_type_changing.connect(_on_Parts_entry_type_changing)

func _open():
	super()
	var key = _a_key_entry.get_key()
	_a_Attributes.set_key(key)

func _close():
	super()
	_close_attributes()

func _open_attributes():
	var data = _a_part.get_data()
	var type = _a_part.get_type()
	_a_Attributes.open(data[type])

func _close_attributes():
	_a_Attributes.close()

func _update_part_data():
	# Update data of a_part_instance
	if !is_instance_valid(_a_part):
		return
	
	var type = _a_part.get_type()
	var data = _a_Attributes.get_save_data()
	_a_part.set_data_type(type, data)

func _selected_part_changed(p_instance):
	if is_instance_valid(_a_part):
		_close_attributes()
	super(p_instance)
	
	_open_attributes()

func _on_Dialogues_key_changed(p_old, p_new):
	var data = _get_data()
	for state_key in data:
		var state_data = data[state_key]["Data"]
		for state_entry_key in state_data:
			var state_args = state_data[state_entry_key]
			for state_type in state_args["Data"]:
				var state_type_args = state_args["Data"][state_type]
				if state_type_args.is_empty():
					continue
				
				var actions_data = state_type_args["Actions"]
				for action_entry_key in actions_data:
					var action_args = actions_data[action_entry_key]
					for entry_args in action_args["Editor"]:
						Debug.fix_data_dialogue_key(entry_args, p_old, p_new)

func _on_Dialogues_part_moved(p_old_idx, p_new_idx, p_shift_others):
	var idx_shifts = {}
	idx_shifts[p_old_idx] = p_new_idx
	if p_shift_others:
		if p_old_idx < p_new_idx:
			for idx in range(p_old_idx + 1, p_new_idx + 1):
				idx_shifts[idx] = idx - 1
		else:
			for idx in range(p_new_idx, p_old_idx):
				idx_shifts[idx] = idx + 1
	
	var data = _get_data()
	for state_key in data:
		var state_data = data[state_key]["Data"]
		for state_entry_key in state_data:
			var state_args = state_data[state_entry_key]
			for state_type in state_args["Data"]:
				var state_type_args = state_args["Data"][state_type]
				if state_type_args.is_empty():
					continue
				
				var actions_data = state_type_args["Actions"]
				for action_entry_key in actions_data:
					var action_args = actions_data[action_entry_key]
					for entry_args in action_args["Editor"]:
						Debug.fix_data_dialogue_part_idx(entry_args, idx_shifts)

func _on_visibility_changed():
	super()
	_a_Attributes.action_set_editor_active(visible)

func _on_Parts_entry_type_changed(p_instance):
	if _a_part != p_instance:
		return
	
	_close_attributes()
	_open_attributes()

func _on_Parts_entry_type_changing():
	_update_part_data()
