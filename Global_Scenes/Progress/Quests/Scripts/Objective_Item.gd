extends "res://Global_Scenes/Progress/Quests/Scripts/Objective_Int.gd"

@export var _e_item_key = ""
@export var _e_track_init = true # Track initial item amount?
@export var _e_track_gain = true # Track item gain?
@export var _e_track_loss = false # Track item loss?

func _ready():
	if _e_track_init && !_e_item_key.is_empty():
		var global_si = Global.get_singleton(self, "Global")
		_a_value = global_si.get_item_amount(_e_item_key)

func _connect_item_amount_changed():
	if !_e_item_key.is_empty():
		var global_si = Global.get_singleton(self, "Global")
		global_si.item_amount_changed.connect(_on_Global_item_amount_changed)

func load_file_data(p_data):
	super(p_data)
	if _a_active:
		_connect_item_amount_changed()

func load_data_init():
	super()
	_connect_item_amount_changed()

func _on_Global_item_amount_changed(p_key, _p_amount, p_diff):
	if p_key != _e_item_key:
		return
	if !_e_track_gain && p_diff > 0:
		return
	if !_e_track_loss && p_diff < 0:
		return
	
	var target_value = _e_data.get_target_value()
	var curr_value = _a_value
	_a_value += p_diff
	if curr_value > target_value && _a_value < target_value:
		_a_value = max(target_value, _a_value)
	if curr_value < target_value && _a_value > target_value:
		_a_value = min(target_value, _a_value)
	progressed.emit()
	
	if _a_value == target_value:
		var global_si = Global.get_singleton(self, "Global")
		global_si.item_amount_changed.disconnect(_on_Global_item_amount_changed)
		_completed()
