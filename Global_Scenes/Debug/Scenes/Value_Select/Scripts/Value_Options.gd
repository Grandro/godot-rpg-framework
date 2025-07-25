extends "res://Global_Scenes/Debug/Scenes/Value_Select/Scripts/Value_Select.gd"

signal selected()

@export var _e_init_key : String = ""
@export var _e_options_loc_id : String = ""
@export var _e_options : Array = []

@onready var _a_Value = get_node("Value")

var _a_options = {} # Match key to value
var _a_option_idxs = {} # Match key to idx

func _ready():
	super()
	_a_Value.item_selected.connect(_on_Value_item_selected)

func select(p_key):
	var idx = _a_option_idxs[p_key]
	_a_Value.select(idx)

func add(p_key, p_value = null):
	var idx = _a_Value.get_item_count()
	_a_options[p_key] = p_value
	_a_option_idxs[p_key] = idx
	_a_Value.add_item(p_key)
	_a_Value.set_item_metadata(idx, p_key)

func update_options():
	_clear_options()
	
	for i in _e_options.size():
		var option = _e_options[i]
		var text = str(option)
		if !_e_options_loc_id.is_empty():
			text = tr(_e_options_loc_id % text.to_upper())
		_a_option_idxs[option] = i
		_a_Value.add_item(text)
		_a_Value.set_item_metadata(i, option)

func _clear_options():
	_a_Value.clear()
	_a_options.clear()
	_a_option_idxs.clear()

func set_options(p_options):
	_e_options = p_options

func get_count():
	return _a_Value.get_item_count()

func get_selected_key():
	return _a_Value.get_selected_metadata()

func get_key(p_idx):
	return _a_Value.get_item_metadata(p_idx)

func has_key(p_key):
	return _a_option_idxs.has(p_key)

func get_idx(p_key):
	return _a_option_idxs[p_key]

func get_value(p_idx):
	var key = _a_Value.get_item_metadata(p_idx)
	return _a_options[key]

func get_selected_value():
	var key = _a_Value.get_selected_metadata()
	return _a_options[key]

func get_selected_id():
	return _a_Value.get_selected_id()

func set_disabled(p_disabled):
	_a_Value.set_disabled(p_disabled)

func get_save_data():
	var data = super()
	data["Value"] = _a_Value.get_selected_metadata()
	
	return data

func load_data(p_data):
	super(p_data)
	
	var key = p_data["Value"]
	if key != null:
		var idx = _a_option_idxs[key]
		_a_Value.select(idx)

func load_data_init():
	super()
	if _e_init_key.is_empty():
		if _a_Value.get_item_count() > 0:
			_a_Value.select(0)
	else:
		select(_e_init_key)

func _on_Var_Select_active_toggled(p_toggled):
	_a_Value.set_disabled(p_toggled)

func _on_Value_item_selected(_p_idx):
	selected.emit()
