extends Node

signal progressed()
signal completed()

@export var _e_data: ObjectiveData = null

var _a_active = true
var _a_value = null

func _ready():
	if !_a_active:
		return
	
	_update_progress()

func manual_progress():
	pass

func _update_progress():
	pass

func get_data():
	return _e_data

func get_value():
	return _a_value

func get_save_data():
	var data = {}
	data["Active"] = _a_active
	data["Value"] = _a_value
	
	return data

func load_file_data(p_data):
	_a_active = p_data["Active"]
	_a_value = p_data["Value"]

func load_data_init():
	pass
