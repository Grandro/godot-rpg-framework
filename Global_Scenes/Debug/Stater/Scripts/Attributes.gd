extends VBoxContainer

const _a_TYPES_LOC_ID = "DEBUG_STATER_%s"

@onready var _a_Types = get_node("Types")
@onready var _a_Conditions = get_node("Conditions")
@onready var _a_Actions = get_node("Actions")
@onready var _a_Preview = get_node("Preview")

var _a_key = "" # Key_Entry key
var _a_action_entry = null

func _ready():
	_a_Types.toggled.connect(_on_Types_toggled)
	_a_Actions.entry_option_test_selected.connect(_on_Actions_entry_option_test_selected)
	_a_Actions.entry_selectable_focus_entered.connect(_on_Actions_entry_selectable_focus_entered)
	_a_Actions.entry_preview_pressed.connect(_on_Actions_entry_preview_pressed)
	
	_create_types()

func open(p_data):
	for type in p_data:
		var instance = _get_entry_list(type)
		instance.load_data(p_data[type])

func close():
	_a_Conditions.clear_entries()
	_a_Actions.clear_entries()

func action_set_editor_active(p_active):
	if is_instance_valid(_a_action_entry):
		_a_action_entry.set_editor_active(p_active)

func _create_types():
	for type in ["Conditions", "Actions"]:
		var select_text = tr(_a_TYPES_LOC_ID % type.to_upper())
		var instance = _a_Types.instantiate_entry_(select_text, null, type)
		_a_Types.add_entry(instance)

func _instantiate_condition(p_data = {}):
	var global_si = Global.get_singleton(self, "Global")
	var expression_self = global_si.get_object(_a_key)
	var instance = _a_Conditions.instantiate_entry_(p_data, expression_self)
	_a_Conditions.add_entry(instance)

func _instantiate_action(p_data = {}):
	var instance = _a_Actions.instantiate_entry_(p_data)
	_a_Actions.add_entry(instance)

func _get_entry_list(p_type):
	match p_type:
		"Conditions": return _a_Conditions
		"Actions": return _a_Actions

func get_save_data():
	var data = {}
	for type in ["Conditions", "Actions"]:
		var entry_list = _get_entry_list(type)
		data[type] = entry_list.get_save_data()
	
	return data

func set_key(p_key):
	_a_key = p_key

func _on_Types_toggled(p_instance):
	var type = p_instance.get_key()
	_a_Conditions.set_visible(type == "Conditions")
	_a_Actions.set_visible(type == "Actions")

func _on_Actions_entry_option_test_selected(p_cutscene_data, p_skip_idxs):
	_a_Preview.open(p_cutscene_data, p_skip_idxs)

func _on_Actions_entry_selectable_focus_entered(p_instance):
	if p_instance == _a_action_entry:
		return
	
	if is_instance_valid(_a_action_entry):
		_a_action_entry.set_editor_active(false)
	
	p_instance.set_editor_active(true)
	_a_action_entry = p_instance

func _on_Actions_entry_preview_pressed(p_cutscene_data):
	_a_Preview.open(p_cutscene_data, [])
