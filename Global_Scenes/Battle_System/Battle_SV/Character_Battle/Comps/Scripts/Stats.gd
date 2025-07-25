extends Node

@export var _e_max : Array[String] = ["HP", "SP"]
@export var _e_curr : Array[String] = ["HP", "SP", "ATK", "MAG", "DEF", "SPEED", "LUCK"]

signal stat_changed(p_stat, p_value)

var _a_status_effects = {} # Match stat_key to status effects

var _a_max = {} # Match stat_key to stat_value
var _a_curr = {} # Match stat_key to stat_value

func _ready():
	for key in _e_curr:
		_a_status_effects[key] = []
	
	for key in _e_max:
		_a_max[key] = -1
	for key in _e_curr:
		_a_curr[key] = -1

func init(_p_entity):
	pass

func register_status_effect(p_instance):
	var stat = p_instance.get_stat()
	_a_status_effects[stat].push_back(p_instance)

func deregister_status_effect(p_instance):
	var stat = p_instance.get_stat()
	_a_status_effects[stat].erase(p_instance)

func decrease_curr_stat(p_stat, p_amount):
	var value = _a_curr[p_stat]
	set_curr_stat(p_stat, value - p_amount)

func set_max_stat(p_stat, p_value):
	_a_max[p_stat] = p_value
	if _a_curr[p_stat] > p_value:
		set_curr_stat(p_stat, p_value)

func set_curr_stat(p_stat, p_value):
	var value = _a_curr[p_stat]
	if _a_max.has(p_stat):
		_a_curr[p_stat] = min(p_value, _a_max[p_stat])
	else:
		_a_curr[p_stat] = p_value
	_a_curr[p_stat] = max(_a_curr[p_stat], 0)
	
	if value != _a_curr[p_stat]:
		stat_changed.emit(p_stat, _a_curr[p_stat])

func get_max_stat(p_stat):
	return _a_max[p_stat]

func get_curr_stat(p_stat):
	var value = _a_curr[p_stat]
	for instance in _a_status_effects[p_stat]:
		value = instance.get_modified_value(value)
	
	return value

func get_save_data():
	return {}

func load_data(_p_data):
	pass

func load_data_init():
	pass
