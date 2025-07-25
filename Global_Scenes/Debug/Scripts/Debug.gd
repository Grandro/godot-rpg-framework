extends Node

signal loc_data_loaded()
signal closing()

@export var _e_enabled: bool = true

const _a_DEFAULT_VOX_FILE_PATH = "res://Global_Scenes/Dialogue_System/Audio/Vox/Default.ogg"

@onready var _a_Teleport_Map = get_node("Teleport_Map")
@onready var _a_Window = get_node("Window")
@onready var _a_Menu = get_node("Window/Control/Menu")
@onready var _a_Dialogues = get_node("Window/Control/Menu/Dialogues")
@onready var _a_Stater = get_node("Window/Control/Menu/Stater")
@onready var _a_Cutscenes = get_node("Window/Control/Menu/Cutscenes")
@onready var _a_Localization = get_node("Window/Control/Menu/Localization")
@onready var _a_Commands_List = get_node("Window/Commands_List")
@onready var _a_Command_Edit = get_node("Window/Command_Edit")
@onready var _a_Fix_Warnings = get_node("Window/Fix_Warnings")
@onready var _a_Attr_Select = get_node("Window/Attr_Select")
@onready var _a_Loc_Editor = get_node("Window/Loc_Editor/Loc_Editor")
@onready var _a_Messages = get_node("Window/Messages")

var _a_loc_data = {}
var _a_loc_data_modified_time = -1.0
var _a_command_editor_clipboard = []

var _a_curr_menu_tab = null

func _ready():
	if !_e_enabled || !OS.is_debug_build():
		await get_tree().process_frame
		queue_free()
		return
	
	var root = get_tree().get_root()
	closing.connect(_on_closing)
	root.focus_entered.connect(_on_Window_focus_entered)
	_a_Window.close_requested.connect(_on_Window_close_requested)
	_a_Window.focus_entered.connect(_on_Window_focus_entered)
	_a_Menu.tab_changed.connect(_on_Menu_tab_changed)
	_a_Dialogues.key_changed.connect(_a_Stater._on_Dialogues_key_changed)
	_a_Dialogues.part_moved.connect(_a_Stater._on_Dialogues_part_moved)
	_a_Dialogues.key_changed.connect(_a_Cutscenes._on_Dialogues_key_changed)
	_a_Dialogues.part_moved.connect(_a_Cutscenes._on_Dialogues_part_moved)
	_a_Localization.trans_changed.connect(_on_Localization_trans_changed)
	
	_a_loc_data = Data_Parser.load_loc_data()
	_a_loc_data_modified_time = FileAccess.get_modified_time(Data_Parser.a_LOC_PATH)
	loc_data_loaded.emit()
	
	_a_Window.hide()

func _unhandled_input(p_event):
	if p_event.is_action_pressed("Open_Debug"):
		if _a_Window.is_visible():
			closing.emit()
			close()
		else:
			open()

func open():
	Global.pause()
	_a_Window.show()

func close():
	Global.unpause()
	set_openable(true)
	_a_Window.hide()

func open_teleport_map():
	_a_Teleport_Map.open()

func grab_window_focus():
	_a_Window.grab_focus()

func show_menu():
	set_openable(true)
	_a_Window.show()

func hide_menu():
	set_openable(false)
	_a_Window.hide()

func update_all_trans():
	var instances = get_tree().get_nodes_in_group("Translated")
	for instance in instances:
		instance.update_trans()

func add_loc_id(p_loc_id, p_value = {}):
	if p_value.is_empty():
		var locales = TranslationServer.get_loaded_locales()
		for locale in locales:
			p_value[locale] = "-"
	
	_a_loc_data[p_loc_id] = p_value

func erase_loc_id(p_id):
	_a_loc_data.erase(p_id)

func fix_data_dialogue_key(p_args, p_old, p_new):
	if p_args["Args"].has("Branches"):
		for branch in p_args["Args"]["Branches"]:
			var branch_args = p_args["Args"]["Branches"][branch]
			for entry_args in branch_args["Entries"]:
				fix_data_dialogue_key(entry_args, p_old, p_new)
	
	var command = p_args["Command"]
	match command:
		"Match":
			var choices_data = p_args["Data"]["Menus"]["Choices"]
			var key = choices_data["Dialogue"]["Value"]
			if key == p_old:
				choices_data["Dialogue"]["Value"] = p_new
		
		"Show_Dialogue":
			var key = p_args["Data"]["Key"]["Value"]
			if key == p_old:
				p_args["Data"]["Key"]["Value"] = p_new

func fix_data_dialogue_part_idx(p_args, p_idx_shifts):
	if p_args["Args"].has("Branches"):
		for branch in p_args["Args"]["Branches"]:
			var branch_args = p_args["Args"]["Branches"][branch]
			for entry_args in branch_args["Entries"]:
				fix_data_dialogue_part_idx(entry_args, p_idx_shifts)
	
	var command = p_args["Command"]
	match command:
		"Match":
			var choices_data = p_args["Data"]["Menus"]["Choices"]
			var part_idx = choices_data["Part"]["Value"]
			for old_idx in p_idx_shifts:
				if part_idx == old_idx:
					choices_data["Part"]["Value"] = p_idx_shifts[old_idx]
					break

func set_openable(p_openable):
	set_process_unhandled_input(p_openable)

func get_commands_list():
	return _a_Commands_List

func get_command_edit():
	return _a_Command_Edit

func get_fix_warnings():
	return _a_Fix_Warnings

func get_attr_select():
	return _a_Attr_Select

func get_loc_editor():
	return _a_Loc_Editor

func get_messages():
	return _a_Messages

func set_command_editor_clipboard(p_command_editor_clipboard):
	_a_command_editor_clipboard = p_command_editor_clipboard

func get_command_editor_clipboard():
	return _a_command_editor_clipboard

func get_loc_data():
	return _a_loc_data

func is_type_tween_supported(p_type):
	if p_type == TYPE_BOOL || p_type == TYPE_INT:
		return true
	if p_type == TYPE_FLOAT || p_type == TYPE_VECTOR2:
		return true
	if p_type == TYPE_RECT2 || p_type == TYPE_VECTOR3:
		return true
	if p_type == TYPE_TRANSFORM2D || p_type == TYPE_QUATERNION:
		return true
	if p_type == TYPE_AABB || p_type == TYPE_BASIS:
		return true
	if p_type == TYPE_TRANSFORM3D || p_type == TYPE_COLOR:
		return true
	
	return false

func is_usage_for_editor(p_usage):
	if p_usage == 0:
		return true
	if Global.is_bit_enabled(p_usage, 0):
		return true
	if Global.is_bit_enabled(p_usage, 1):
		return true
	if Global.is_bit_enabled(p_usage, 2):
		return true
	if Global.is_bit_enabled(p_usage, 12):
		return true
	
	return false

func _on_closing():
	_a_Commands_List.close()
	_a_Command_Edit.close()

func _on_request_hide():
	set_openable(false)
	_a_Window.hide()

func _on_request_close():
	close()

func _on_Window_close_requested():
	close()

func _on_Window_focus_entered():
	if !_e_enabled || !OS.is_debug_build():
		return
	
	var modified_time = FileAccess.get_modified_time(Data_Parser.a_LOC_PATH)
	if modified_time > _a_loc_data_modified_time:
		_a_loc_data = Data_Parser.load_loc_data()
		_a_loc_data_modified_time = modified_time
		loc_data_loaded.emit()

func _on_Menu_tab_changed(p_idx):
	var instance = _a_Menu.get_tab_control(p_idx)
	if instance == _a_Localization:
		_a_Localization.open()
	elif _a_curr_menu_tab == _a_Localization:
		_a_Localization.close()
	
	_a_curr_menu_tab = instance

func _on_Localization_trans_changed():
	update_all_trans()
