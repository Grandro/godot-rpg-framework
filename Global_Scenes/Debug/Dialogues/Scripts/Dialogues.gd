extends "res://Global_Scenes/Debug/Keys_Editor/Scripts/Keys_Editor_Parts.gd"

signal part_moved(p_old_idx, p_new_idx, shift_others)

@onready var _a_Options_Preview_All = get_node("VBox/HBox/VBox/Options/Preview_All")
@onready var _a_Attributes = get_node("VBox/HBox/VBox/Attributes")
@onready var _a_Text = get_node("VBox/HBox/VBox/Attributes/Text")
@onready var _a_Info = get_node("VBox/HBox/VBox/Attributes/Info")
@onready var _a_Choice = get_node("VBox/HBox/VBox/Attributes/Choice")

var _a_attr_instance = null

func _ready():
	super()
	_a_Parts.entry_type_changed.connect(_on_Parts_entry_type_changed)
	_a_Parts.entry_type_changing.connect(_on_Parts_entry_type_changing)
	_a_Parts.entry_moved.connect(_on_Parts_entry_moved)
	_a_Parts.entry_tree_exited.connect(_on_Parts_entry_tree_exited)
	_a_Options_Preview_All.pressed.connect(_on_Options_Preview_All_pressed)
	
	for child in _a_Attributes.get_children():
		child.hide()

func _open_attributes():
	var data = _a_part.get_data()
	var type = _a_part.get_type()
	match type:
		"Text": _a_attr_instance = _a_Text
		"Info": _a_attr_instance = _a_Info
		"Choice": _a_attr_instance = _a_Choice
	_a_attr_instance.open(data[type])

func _close_attributes():
	if _a_attr_instance != null:
		_a_attr_instance.close()
		_a_attr_instance = null

func _update_part_data():
	# Update data of _a_part
	if !is_instance_valid(_a_part):
		return
	
	var type = _a_part.get_type()
	var save_data = _a_attr_instance.get_save_data()
	_a_part.set_data_type(type, save_data)

func _selected_part_changed(p_instance):
	super(p_instance)
	_close_attributes()
	_open_attributes()

func _set_keys_type(p_keys_type):
	super(p_keys_type)
	for child in _a_Attributes.get_children():
		child.set_tabs_keys_type(p_keys_type)

func _on_Parts_entry_type_changed(p_instance):
	if _a_part != p_instance:
		return
	
	_close_attributes()
	_open_attributes()

func _on_Parts_entry_type_changing():
	_update_part_data()

func _on_Parts_entry_moved(p_old_idx, p_new_idx):
	part_moved.emit(p_old_idx, p_new_idx, true)

func _on_Parts_entry_tree_exited(p_idx):
	var child_count = _a_Parts.get_entry_count()
	for i in range(p_idx, child_count):
		part_moved.emit(i + 1, i, false)

func _on_Options_Preview_pressed():
	super()
	Debug.hide_menu()
	
	var key = _a_key_entry.get_key()
	var idx = _a_part.get_index()
	Dialogue_System.dialogue(key, null, "Main", true, idx, idx, _a_keys_type)
	Dialogue_System.set_dialogue_completed_cb(key, _CB_dialogue_completed)
	Dialogue_System.set_dialogue_process_mode(key, ProcessMode.PROCESS_MODE_ALWAYS)

func _on_Options_Preview_All_pressed():
	_update_parts_data()
	Debug.hide_menu()
	
	var key = _a_key_entry.get_key()
	Dialogue_System.dialogue(key, null, "Main", true, 0, -1, _a_keys_type)
	Dialogue_System.set_dialogue_completed_cb(key, _CB_dialogue_completed)
	Dialogue_System.set_dialogue_process_mode(key, ProcessMode.PROCESS_MODE_ALWAYS)

func _CB_dialogue_completed(_p_key):
	Debug.show_menu()

func MESSAGES_PROCEED(p_response, p_args):
	if p_response == "Yes":
		var type = p_args[0]
		if type == "Part":
			var instance = p_args[1]
			if _a_part == instance:
				_close_attributes()
				_a_part = null
			instance.queue_free()
