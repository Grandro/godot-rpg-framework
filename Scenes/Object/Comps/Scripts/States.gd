extends Node

signal state_tmp_changed(p_state_tmp)

@export var _e_states: Array[String] = []
@export var _e_state: String = ""

var _a_state_tmp = _e_state

func init(_p_entity):
	set_state_tmp(_e_state)

func revert_state_tmp():
	set_state_tmp(_e_state)

func get_states():
	return _e_states

func set_state(p_state):
	_e_state = p_state
	set_state_tmp(p_state)

func get_state():
	return _e_state

func has_state(p_state):
	return _e_states.has(p_state)

func set_state_tmp(p_state_tmp):
	_a_state_tmp = p_state_tmp
	state_tmp_changed.emit(p_state_tmp)

func get_state_tmp():
	return _a_state_tmp

func get_save_data():
	var data = {}
	data["State"] = get_state()
	data["State_Tmp"] = get_state_tmp()
	
	return data

func load_data(p_data):
	set_state(p_data["State"])
	set_state_tmp(p_data["State_Tmp"])

func load_data_init():
	pass
