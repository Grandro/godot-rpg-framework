extends "res://Global_Scenes/Debug/Keys_Editor/Scripts/Keys_Editor_Parts.gd"

@onready var _a_Editor = get_node("VBox/HBox/VBox/Editor")
@onready var _a_Preview = get_node("Preview")

func _ready():
	super()
	_a_Editor.option_test_selected.connect(_on_Editor_option_test_selected)

func _open_preview(p_skip_idxs = []):
	var cutscene_data = _a_Editor.get_cutscene_data()
	_a_Preview.open(cutscene_data, p_skip_idxs)

func _update_part_data():
	# Update data of a_part_instance
	if !is_instance_valid(_a_part):
		return
	
	var type = _a_part.get_type()
	var save_data = _a_Editor.get_save_data()
	_a_part.set_data_type(type, save_data)

func _selected_part_changed(p_instance):
	super(p_instance)
	
	var data = _a_part.get_data()
	var type = _a_part.get_type()
	_a_Editor.update_entries(data[type])

func _on_Parts_Add_Select_pressed():
	_a_Parts.instantiate_part_entry("Default")

func _on_Options_Preview_pressed():
	super()
	
	var skip_idxs = _a_Editor.get_skip_idxs()
	_open_preview(skip_idxs)

func _on_visibility_changed():
	super()
	_a_Editor.set_active(visible)

func _on_Editor_option_test_selected(p_instance):
	var skip_idxs = _a_Editor.get_skip_idxs(p_instance)
	_open_preview(skip_idxs)

func _on_Dialogues_key_changed(p_old, p_new):
	var data = _get_data()
	for cutscene_key in data:
		var cutscene_data = data[cutscene_key]["Data"]
		for cutscene_entry_key in cutscene_data:
			var cutscene_args = cutscene_data[cutscene_entry_key]
			for entry_args in cutscene_args["Data"]["Default"]:
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
	for cutscene_key in data:
		var cutscene_data = data[cutscene_key]["Data"]
		for cutscene_entry_key in cutscene_data:
			var cutscene_args = cutscene_data[cutscene_entry_key]
			for entry_args in cutscene_args["Data"]["Default"]:
				Debug.fix_data_dialogue_part_idx(entry_args, idx_shifts)
