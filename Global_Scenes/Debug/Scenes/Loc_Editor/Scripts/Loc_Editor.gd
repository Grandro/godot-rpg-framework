extends MarginContainer

signal loc_id_selected(p_loc_id)
signal trans_changed()
signal closed()

var _a_Trans_Entry_Scene = preload("res://Global_Scenes/Debug/Scenes/Loc_Editor/Trans_Entry.tscn")
var _a_Group_Entry_Scene = preload("res://Global_Scenes/Debug/Scenes/Loc_Editor/Group_Entry.tscn")

@export_enum("Select", "Edit") var _e_mode = "Select"
@export_enum("Global", "Map") var _e_loc_id_type = "Global"
@export var _e_show_return: bool = true

const _a_TRANS_PATH = "res://Localization/Localization.%s.translation"
const _a_KEYS_TYPE_LOC_ID = "DEBUG_TYPE_%s"

@onready var _a_Loc_ID_Types = get_node("Margin/VBox/Up/Loc_ID_Types")
@onready var _a_Save = get_node("Margin/VBox/Up/Options/Save")
@onready var _a_Back = get_node("Margin/VBox/Up/Options/Back")
@onready var _a_Groups_Scroll = get_node("Margin/VBox/Down/Groups/Scroll")
@onready var _a_Groups = get_node("Margin/VBox/Down/Groups/Scroll/VBox")
@onready var _a_Add = get_node("Margin/VBox/Down/Groups/Add")
@onready var _a_Add_Input = get_node("Margin/VBox/Down/Groups/Add/Input")
@onready var _a_Add_Select = get_node("Margin/VBox/Down/Groups/Add/Select")
@onready var _a_Select = get_node("Margin/VBox/Down/Groups/Select")
@onready var _a_Loc_ID = get_node("Margin/VBox/Down/Trans/Margin/Entries/Loc_ID")
@onready var _a_Heading = get_node("Margin/VBox/Down/Trans/Margin/Entries/VBox/Heading")
@onready var _a_Trans = get_node("Margin/VBox/Down/Trans/Margin/Entries/VBox/Scroll/VBox")

var _a_loc_id = "" # loc_id of currently focused Loc_ID_Entry
var _a_group_entries = {} # Match group name to instance
var _a_trans = {} # Match locale to Translation Resource

func _ready():
	_a_Loc_ID_Types.toggled.connect(_on_Loc_ID_Types_toggled)
	_a_Save.pressed.connect(_on_Save_pressed)
	_a_Back.pressed.connect(_on_Back_pressed)
	_a_Add_Select.pressed.connect(_on_Add_Select_pressed)
	_a_Select.pressed.connect(_on_Select_pressed)
	Scene_Manager.scene_changed.connect(_on_Scene_Manager_scene_changed)
	
	_a_Loc_ID.set_message_translation(false)
	_a_Heading.set_text("[u]%s" % tr("DEBUG_TRANS"))
	
	var locales = TranslationServer.get_loaded_locales()
	for locale in locales:
		var path = _a_TRANS_PATH % locale
		var trans = load(path)
		_a_trans[locale] = trans
	
	set_mode(_e_mode)
	_create_loc_id_types()
	
	if !_e_show_return:
		_a_Back.hide()
	hide()

func update_trans():
	_a_Select.set_text(tr("SELECT"))
	_a_Heading.set_text("[u]%s" % tr("DEBUG_TRANS"))

func open(p_group = "", p_loc_id = ""):
	_update_groups()
	
	show()
	
	if !p_loc_id.is_empty():
		p_group = _get_group(p_loc_id)
	
	if !p_group.is_empty() && _a_group_entries.has(p_group):
		var group_instance = _a_group_entries[p_group]
		group_instance.set_expanded(true)
		
		var group_loc_ids = group_instance.get_loc_ids()
		var loc_id_instance = null
		if !p_loc_id.is_empty() && group_loc_ids.has(p_loc_id):
			loc_id_instance = group_instance.get_entry(p_loc_id)
		else:
			loc_id_instance = group_instance.get_first_entry()
		
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
		loc_id_instance.grab_select_focus()
		_a_Groups_Scroll.ensure_control_visible(loc_id_instance)

func close():
	_clear_groups()
	
	closed.emit()
	hide()

func toggle_loc_id_types(p_loc_id_type):
	_a_Loc_ID_Types.toggle(p_loc_id_type)

func _clear_groups():
	_a_group_entries.clear()
	for child in _a_Groups.get_children():
		child.queue_free()

func _create_loc_id_types():
	for loc_id_type in ["Map", "Global"]:
		var select_text = tr(_a_KEYS_TYPE_LOC_ID % loc_id_type.to_upper())
		var instance = _a_Loc_ID_Types.instantiate_entry_(select_text, null, loc_id_type)
		_a_Loc_ID_Types.add_entry(instance)

func _instantiate_group(p_group):
	var instance = _a_Group_Entry_Scene.instantiate()
	instance.entry_deleting.connect(_on_Group_Entry_entry_deleting.bind(p_group))
	instance.entry_select_focus_entered.connect(_on_Group_Entry_entry_select_focus_entered)
	instance.entry_loc_id_changed.connect(_on_Group_Entry_entry_loc_id_changed.bind(p_group))
	instance.set_text.call_deferred(p_group)
	instance.set_group(p_group)
	instance.set_loc_id_type(_e_loc_id_type)
	
	_a_group_entries[p_group] = instance
	
	return instance

func _update_groups():
	_clear_groups()
	
	for loc_id in Debug.get_loc_data():
		var group = _get_group(loc_id)
		var instance = _get_or_create_group_instance(group)
		instance.add_loc_id(loc_id)

func _clear_trans():
	_a_Loc_ID.set_text("-")
	for child in _a_Trans.get_children():
		child.queue_free()

func _update_trans(p_instance):
	_clear_trans()
	
	var loc_id = p_instance.get_loc_id()
	var loc_data = Debug.get_loc_data()
	var data = loc_data[loc_id]
	for locale in data:
		var text = data[locale]
		var instance = _a_Trans_Entry_Scene.instantiate()
		instance.text_changed.connect(_on_Trans_Entry_text_changed.bind(p_instance, locale))
		instance.set_heading.call_deferred(locale)
		instance.set_text.call_deferred(text)
		if _e_mode == "Select":
			instance.set_text_editable.call_deferred(false)
		
		_a_Trans.add_child(instance)
	
	_a_Loc_ID.set_text(loc_id)

func _remove_loc_id(p_group, p_loc_id):
	var group_instance = _a_group_entries[p_group]
	group_instance.remove_loc_id(p_loc_id)
	Debug.erase_loc_id(p_loc_id)
	
	var group_loc_ids = group_instance.get_loc_ids()
	if group_loc_ids.is_empty():
		group_instance.queue_free()
		_a_group_entries.erase(p_group)
		
		_clear_trans()

func set_mode(p_mode):
	match p_mode:
		"Select":
			_a_Save.hide()
			_a_Add.hide()
			_a_Select.show()
		
		"Edit":
			_a_Save.show()
			_a_Add.show()
			_a_Select.hide()
	
	_e_mode = p_mode

func _get_group(p_loc_id):
	var group = "_Misc"
	var sep_idx = p_loc_id.find("_")
	if sep_idx != -1:
		var prefix = p_loc_id.substr(0, sep_idx)
		group = prefix.capitalize()
	
	return group

func _get_used_loc_ids():
	var loc_data = Debug.get_loc_data()
	var loc_ids = loc_data.keys()
	
	return loc_ids

func _get_or_create_group_instance(p_group):
	var instance = null
	if _a_group_entries.has(p_group):
		instance = _a_group_entries[p_group]
	else:
		instance = _instantiate_group(p_group)
		_a_Groups.add_child(instance)
	
	return instance

func _on_Loc_ID_Types_toggled(p_instance):
	_e_loc_id_type = p_instance.get_key()
	
	for group in _a_group_entries:
		var group_instance = _a_group_entries[group]
		group_instance.set_loc_id_type(_e_loc_id_type)

func _on_Save_pressed():
	var loc_ids = []
	for child in _a_Groups.get_children():
		var child_loc_ids = child.get_loc_ids()
		loc_ids.append_array(child_loc_ids)
	
	Data_Parser.write_loc_data(loc_ids)

func _on_Back_pressed():
	close()

func _on_Add_Select_pressed():
	var loc_id = _a_Add_Input.get_text()
	if loc_id.is_empty():
		return
	
	var used_loc_ids = _get_used_loc_ids()
	if used_loc_ids.has(loc_id):
		return
	
	_a_Add_Input.clear()
	
	var locales = TranslationServer.get_loaded_locales()
	for locale in locales:
		var trans = _a_trans[locale]
		trans.add_message(loc_id, "")
	Debug.add_loc_id(loc_id)
	
	var group = _get_group(loc_id)
	var group_instance = _get_or_create_group_instance(group)
	group_instance.add_loc_id(loc_id)

func _on_Select_pressed():
	loc_id_selected.emit(_a_loc_id)
	close()

func _on_Scene_Manager_scene_changed(_p_instance, _p_loaded_file_data):
	if Scene_Manager.is_curr_scene_map_encounter():
		toggle_loc_id_types("Map")
	else:
		toggle_loc_id_types("Global")

func _on_Group_Entry_entry_select_focus_entered(p_instance):
	_update_trans(p_instance)
	_a_loc_id = p_instance.get_loc_id()

func _on_Group_Entry_entry_loc_id_changed(p_loc_id, p_instance, p_old_group):
	p_instance.set_input_text("")
	
	var loc_id = p_instance.get_loc_id()
	if p_loc_id.is_empty() || loc_id == p_loc_id:
		return
	
	var used_loc_ids = _get_used_loc_ids()
	if used_loc_ids.has(p_loc_id):
		return
	
	var loc_data = Debug.get_loc_data()
	var new_group = _get_group(p_loc_id)
	
	var locales = loc_data[loc_id].keys()
	for locale in locales:
		var trans = _a_trans[locale]
		trans.erase_message(loc_id)
		trans.add_message(p_loc_id, loc_data[loc_id][locale])
	
	Debug.add_loc_id(p_loc_id, loc_data[loc_id])
	trans_changed.emit()
	
	var new_group_instance = _get_or_create_group_instance(new_group)
	new_group_instance.add_loc_id(p_loc_id)
	_remove_loc_id(p_old_group, loc_id)

func _on_Group_Entry_entry_deleting(p_instance, p_group):
	var loc_id = p_instance.get_loc_id()
	for trans in _a_trans.values():
		trans.erase_message(loc_id)
	trans_changed.emit()
	
	_remove_loc_id(p_group, loc_id)

func _on_Trans_Entry_text_changed(p_text, p_instance, p_locale):
	var loc_id = p_instance.get_loc_id()
	var trans = _a_trans[p_locale]
	trans.erase_message(loc_id)
	trans.add_message(loc_id, p_text)
	trans_changed.emit()
	
	var loc_data = Debug.get_loc_data()
	loc_data[loc_id][p_locale] = p_text
