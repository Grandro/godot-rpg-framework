extends "res://Global_Scenes/Debug/Command_Editor/Entries/Scripts/Entry_Base.gd"

signal arg_focus_entered()
signal arg_right_clicked(p_pos)
signal warning_pressed(p_pos)
signal mark_changed(p_mark)

@export var _e_color: Color = Color.WHITE

var _a_Arg_Entry_Scene = preload("res://Global_Scenes/Debug/Command_Editor/Entries/Arg_Entry.tscn")

var _a_data = {}
var _a_args = {}
var _a_warnings = []

func _ready():
	super()
	_a_Main.warning_pressed.connect(_on_Main_warning_pressed)

func connect_to_editor(p_editor):
	super(p_editor)
	arg_focus_entered.connect(p_editor._on_Entry_arg_focus_entered.bind(self))
	arg_right_clicked.connect(p_editor._on_Entry_arg_right_clicked.bind(self))
	warning_pressed.connect(p_editor._on_Entry_warning_pressed.bind(self))
	mark_changed.connect(p_editor._on_Entry_mark_changed.bind(self))

func update_data(p_data):
	_a_data = p_data
	
	update_warnings()
	update_display()

func update_warnings():
	_a_warnings.clear()
	
	_update_warnings_add()
	
	var show_warning = !_a_warnings.is_empty()
	_a_Main.set_warning_visible(show_warning)

func update_display():
	_update_display_main_base_desc()
	_update_display_main_base_args()
	_update_display_main_args()
	
	_a_Main.set_base_desc_modulate(_e_color)
	_a_Main.set_base_args_modulate(_e_color)

func _update_warnings_add():
	pass

func _update_warnings_add_expression(p_data, p_value_keys):
	var instance_key = p_data["Instance_Key"]
	var type = p_data["Type"]
	var instance = null
	match type:
		"Object":
			var global_si = Global.get_singleton(self, "Global")
			instance = global_si.get_object(instance_key)
		"Singleton":
			instance = Global.get_singleton(self, instance_key)
		"Curr_Scene":
			var scene_manager_si = Global.get_singleton(self, "Scene_Manager")
			instance = scene_manager_si.get_curr_scene_instance()
	
	if !is_instance_valid(instance):
		var args = _Warning_Args_String.new(instance_key, p_value_keys)
		_a_warnings.push_back(args)

func _update_display_main_base_desc():
	var base_desc_loc_id = "DEBUG_CUTSCENES_COMMANDS_%s" % _a_command.to_upper()
	_a_Main.set_base_desc("%s: " % tr(base_desc_loc_id))

func _update_display_main_base_args():
	pass

func _update_display_main_args():
	for child in _a_Main.get_args_children():
		child.queue_free()

func _instantiate_main_arg(p_desc, p_color):
	var margin = _get_main_arg_margin()
	var instance = _a_Arg_Entry_Scene.instantiate()
	instance.focus_entered.connect(_on_Arg_focus_entered)
	instance.gui_input.connect(_on_Arg_gui_input)
	instance.set_left_margin.call_deferred(margin)
	instance.set_hbox_modulate.call_deferred(p_color)
	instance.set_desc.call_deferred(p_desc)
	
	_a_Main.add_args_child(instance)

func set_args(p_args):
	_a_args = p_args
	
	if _a_args.has("Mark"):
		set_mark(_a_args["Mark"])
	else:
		set_mark("Default")

func get_data():
	return _a_data

func get_cutscene_data():
	return get_save_data()

func get_save_data():
	var data = get_editor_data()
	data["Command"] = _a_command
	
	return data

func get_editor_data():
	var data = {}
	data["Data"] = _a_data.duplicate(true)
	data["Args"] = _a_args.duplicate(true)
	
	return data

func set_mark(p_mark):
	_a_Main.set_mark(p_mark)
	_a_args["Mark"] = p_mark
	mark_changed.emit(p_mark)

func get_entries_count(p_branch_idx = -1):
	var entries = get_entries(p_branch_idx)
	var count = entries.size()
	
	return count

func get_entries(p_branch_idx = -1):
	var entries = []
	if p_branch_idx == -1:
		for branch in _a_Branches.get_children():
			for entry in branch.get_entries():
				entries.push_back(entry)
	else:
		var branch = _a_Branches.get_child(p_branch_idx)
		for entry in branch.get_entries():
			entries.push_back(entry)
	
	return entries

func get_branch_entry(p_branch_idx, p_idx):
	var branch = _a_Branches.get_child(p_branch_idx)
	var entry = branch.get_entry(p_idx)
	
	return entry

func get_warnings():
	return _a_warnings

func _get_main_arg_margin():
	var desc_pos = _a_Main.get_base_margin_min_size()
	var margin = desc_pos.x + 18
	
	return margin

func _get_display_text(p_data):
	var type = p_data["Type"]
	var display_text = ""
	match type:
		"Var": display_text = _get_var_display_text(p_data["Var"])
		"Value": display_text = str(p_data["Value"])
	
	return display_text

func _on_Main_warning_pressed():
	var pos = _a_Main.get_warning_global_pos()
	warning_pressed.emit(pos)

func _on_Arg_focus_entered():
	arg_focus_entered.emit()

func _on_Arg_gui_input(p_event):
	if p_event.is_action_pressed("Mouse_Right"):
		var pos = p_event.get_global_position()
		arg_right_clicked.emit(pos)

class _Warning_Args_Base:
	var _a_type = ""
	var _a_value = null # Invalid value
	var _a_value_keys = [] # Dictionary keys to invalid value
	
	func _init(p_value, p_value_keys):
		_a_value = p_value
		_a_value_keys = p_value_keys
	
	func get_type():
		return _a_type
	
	func get_value():
		return _a_value
		
	func get_value_keys():
		return _a_value_keys

class _Warning_Args_File extends _Warning_Args_Base:
	var _a_dir_path = "" # File: Directory path which should be opened
	var _a_filters = PackedStringArray() # File type filters
	
	func _init(p_value, p_value_keys, p_dir_path, p_filters):
		super(p_value, p_value_keys)
		_a_type = "File"
		_a_dir_path = p_dir_path
		_a_filters = p_filters

class _Warning_Args_Int extends _Warning_Args_Base:
	var _a_min = -1 # Minimum value
	var _a_max = -1 # Maximum value
	
	func _init(p_value, p_value_keys, p_min, p_max):
		super(p_value, p_value_keys)
		_a_type = "Int"
		_a_min = p_min
		_a_max = p_max
	
	func get_min():
		return _a_min
	
	func get_max():
		return _a_max

class _Warning_Args_String extends _Warning_Args_Base:
	func _init(p_value, p_value_keys):
		super(p_value, p_value_keys)
		_a_type = "String"

class _Warning_Args_Range extends _Warning_Args_Int:
	func _init(p_value, p_value_keys, p_min, p_max):
		super(p_value, p_value_keys, p_min, p_max)
		_a_type = "Range"
