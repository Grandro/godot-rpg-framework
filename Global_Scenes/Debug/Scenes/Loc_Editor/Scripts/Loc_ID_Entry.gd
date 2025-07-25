extends "res://Global_Scenes/Debug/Scenes/Entry_List/Entries/Scripts/Entry.gd"

signal select_focus_entered()
signal loc_id_changed(p_loc_id)

var _a_loc_id = ""
var _a_visible_by_loc_id = true

func _ready():
	super()
	_a_Select.focus_entered.connect(_on_Select_focus_entered)

func update_display(p_group, p_type):
	var loc_id_short = _get_loc_id_short_group(p_group)
	if p_type == "Map" && p_group == "Dialogue":
		var location = Scene_Manager.get_location()
		if !location.is_empty():
			loc_id_short = _get_loc_id_short_location(loc_id_short, location)
	
	_a_Name.set_text(loc_id_short)

func update_visible_by_loc_id(p_group, p_type):
	if p_type == "Map" && p_group == "Dialogue":
		var location = Scene_Manager.get_location()
		if location.is_empty():
			_set_visible_by_loc_id(true)
		elif _has_location_prefix(p_group, location):
			_set_visible_by_loc_id(true)
		else:
			_set_visible_by_loc_id(false)
	else:
		_set_visible_by_loc_id(true)

func _update_visibility():
	set_visible(_a_visible_by_search && _a_visible_by_loc_id)

func _handle_copy_action():
	DisplayServer.clipboard_set(_a_loc_id)

func set_loc_id(p_loc_id):
	_a_loc_id = p_loc_id
	_a_Input.set_text(p_loc_id)

func get_loc_id():
	return _a_loc_id

func _set_visible_by_loc_id(p_visible_by_loc_id):
	_a_visible_by_loc_id = p_visible_by_loc_id
	_update_visibility()

func _get_loc_id_short_group(p_group):
	var prefix = "%s_" % p_group.to_upper()
	return _a_loc_id.trim_prefix(prefix)

func _get_loc_id_short_location(p_loc_id_short, p_location):
	var prefix = "%s_" % p_location.to_upper()
	return p_loc_id_short.trim_prefix(prefix)

func _has_location_prefix(p_group, p_location):
	var prefix = "%s_%s_" % [p_group.to_upper(), p_location.to_upper()]
	return _a_loc_id.begins_with(prefix)

func _on_Select_focus_entered():
	select_focus_entered.emit()

func _on_Input_text_submitted(p_text):
	super(p_text)
	loc_id_changed.emit(p_text)
