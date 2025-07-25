extends "res://Global_Scenes/Debug/Scenes/Entry_List/Scripts/Entry_List.gd"

signal entry_select_focus_entered(p_instance)
signal entry_loc_id_changed(p_loc_id, p_instance)

@onready var _a_Expand = get_node("Expand")
@onready var _a_HSep_1 = get_node("HSep_1")
@onready var _a_HSep_2 = get_node("HSep_2")

var _a_group = ""
var _a_loc_id_type = ""
var _a_loc_ids = []
var _a_expanded = false

func _ready():
	super()
	_a_Expand.pressed.connect(_on_Expand_pressed)
	
	set_expanded(false)

func instantiate_entry_(p_loc_id):
	var instance = instantiate_entry(p_loc_id)
	instance.select_focus_entered.connect(_on_Entry_select_focus_entered.bind(instance))
	instance.loc_id_changed.connect(_on_Entry_loc_id_changed.bind(instance))
	instance.set_loc_id.call_deferred(p_loc_id)
	instance.update_display.call_deferred(_a_group, _a_loc_id_type)
	instance.update_visible_by_loc_id.call_deferred(_a_group, _a_loc_id_type)
	
	return instance

func update_entries():
	for loc_id in _a_entries:
		var instance = _a_entries[loc_id]
		instance.update_display(_a_group, _a_loc_id_type)
		instance.update_visible_by_loc_id(_a_group, _a_loc_id_type)

func grab_first_entry_focus():
	for child in _a_VBox.get_children():
		if child.is_visible():
			child.grab_select_focus()
			break

func grab_entry_focus(p_loc_id):
	var instance = _a_entries[p_loc_id]
	instance.grab_select_focus()

func add_loc_id(p_loc_id):
	_a_loc_ids.push_back(p_loc_id)
	if _a_expanded:
		var instance = instantiate_entry_(p_loc_id)
		add_entry(instance)

func remove_loc_id(p_loc_id):
	_a_loc_ids.erase(p_loc_id)
	if _a_expanded:
		var instance = _a_entries[p_loc_id]
		instance.queue_free()

func _instantiate_entries():
	for loc_id in _a_loc_ids:
		var instance = instantiate_entry_(loc_id)
		add_entry(instance)

func set_text(p_text):
	_a_Expand.set_text(p_text)

func set_group(p_group):
	_a_group = p_group

func set_loc_id_type(p_loc_id_type):
	_a_loc_id_type = p_loc_id_type
	update_entries.call_deferred()

func set_expanded(p_expanded):
	_a_Search.set_visible(p_expanded && _e_show_search)
	_a_Scroll.set_visible(p_expanded)
	_a_HSep_1.set_visible(p_expanded)
	_a_HSep_2.set_visible(p_expanded)
	
	if p_expanded:
		_instantiate_entries()
	else:
		clear_entries()
	
	_a_expanded = p_expanded

func get_first_entry():
	for child in _a_VBox.get_children():
		if child.is_visible():
			return child

func get_loc_ids():
	return _a_loc_ids

func get_entry(p_loc_id):
	return _a_entries[p_loc_id]

func get_entries():
	return _a_entries

func _on_Expand_pressed():
	set_expanded(!_a_expanded)

func _on_Entry_select_focus_entered(p_instance):
	entry_select_focus_entered.emit(p_instance)

func _on_Entry_loc_id_changed(p_loc_id, p_instance):
	entry_loc_id_changed.emit(p_loc_id, p_instance)
