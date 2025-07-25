extends VBoxContainer

signal base_focus_entered()
signal base_focus_exited()
signal base_gui_input(p_event)
signal progress_focus_entered()
signal progress_gui_input(p_event)

const _a_FOCUS_COLOR = Color.WHITE
const _a_NORMAL_COLOR = Color.TRANSPARENT

var _a_Collapse_Image = preload("res://Global_Resources/Sprites/UI/Collapse.png")
var _a_Expand_Image = preload("res://Global_Resources/Sprites/UI/Expand.png")

@onready var _a_Base = get_node("Base")
@onready var _a_Base_Outlines = get_node("Base/Outlines")
@onready var _a_Base_Margin = get_node("Base/HBox/Margin")
@onready var _a_Base_Collapse = get_node("Base/HBox/Collapse")
@onready var _a_Base_Desc = get_node("Base/HBox/Desc")
@onready var _a_Process = get_node("Process")
@onready var _a_Process_Outlines = get_node("Process/Outlines")
@onready var _a_Process_Margin = get_node("Process/HBox/Margin")
@onready var _a_Entries = get_node("Entries")

func _ready():
	_a_Base.focus_entered.connect(_on_Base_focus_entered)
	_a_Base.focus_exited.connect(_on_Base_focus_exited)
	_a_Base.gui_input.connect(_on_Base_gui_input)
	_a_Base_Collapse.pressed.connect(_on_Base_Collapse_pressed)
	_a_Process.focus_entered.connect(_on_Process_focus_entered)
	_a_Process.focus_exited.connect(_on_Process_focus_exited)
	_a_Process.gui_input.connect(_on_Process_gui_input)
	
	_a_Base_Collapse.hide()
	_a_Process.hide()

func grab_base_focus():
	_a_Base.grab_focus()

func release_base_focus():
	_a_Base.release_focus()

func set_collapse_visible(p_visible):
	_a_Base_Collapse.set_visible(p_visible)

func set_collapsed(p_collapsed):
	_a_Entries.set_visible(!p_collapsed)
	if p_collapsed:
		_a_Base_Collapse.set_texture_normal(_a_Expand_Image)
	else:
		_a_Base_Collapse.set_texture_normal(_a_Collapse_Image)

func set_process_visible(p_visible):
	_a_Process.set_visible(p_visible)

func has_base_focus():
	return _a_Base.has_focus()

func set_base_focus_mode(p_focus_mode):
	_a_Base.set_focus_mode(p_focus_mode)

func set_base_modulate(p_color):
	_a_Base.set_modulate(p_color)

func set_base_desc(p_desc):
	_a_Base_Desc.set_text(p_desc)

func set_base_desc_modulate(p_color):
	_a_Base_Desc.set_modulate(p_color)

func get_entries_instance():
	return _a_Entries

func set_base_margin_min_size(p_size):
	_a_Base_Margin.set_custom_minimum_size(p_size)

func get_base_margin_min_size():
	return _a_Base_Margin.get_custom_minimum_size()

func get_base_desc_position():
	return _a_Base_Desc.get_position()

func get_process_instance():
	return _a_Process

func get_process_margin_instance():
	return _a_Process_Margin

func get_base_desc_size():
	return _a_Base_Desc.get_size()

func get_entries():
	return _a_Entries.get_children()

func get_entry(p_idx):
	return _a_Entries.get_child(p_idx)

func get_cutscene_data():
	var data = []
	for child in _a_Entries.get_children():
		if !child.is_empty():
			var entry_data = child.get_cutscene_data()
			data.push_back(entry_data)
	
	return data

func get_data():
	var data = {}
	data["Collapsed"] = !_a_Entries.is_visible()
	
	data["Entries"] = []
	for child in _a_Entries.get_children():
		if !child.is_empty():
			var command = child.get_command()
			var child_data = child.get_editor_data()
			child_data["Command"] = command
			data["Entries"].push_back(child_data)
	
	return data

func _on_Base_focus_entered():
	_a_Base_Outlines.set_self_modulate(_a_FOCUS_COLOR)
	base_focus_entered.emit()

func _on_Base_focus_exited():
	_a_Base_Outlines.set_self_modulate(_a_NORMAL_COLOR)
	base_focus_exited.emit()

func _on_Base_gui_input(p_event):
	base_gui_input.emit(p_event)

func _on_Base_Collapse_pressed():
	var collapsed = _a_Entries.is_visible()
	set_collapsed(collapsed)

func _on_Process_focus_entered():
	_a_Process_Outlines.set_self_modulate(_a_FOCUS_COLOR)
	progress_focus_entered.emit()

func _on_Process_focus_exited():
	_a_Process_Outlines.set_self_modulate(_a_NORMAL_COLOR)

func _on_Process_gui_input(p_event):
	progress_gui_input.emit(p_event)
