extends Node

signal completed()

@onready var _a_Objectives = get_node("Objectives")

var _a_active = true # Is quest active or completed?
var _a_completed_objectives_amount = 0

func _ready():
	for child in _a_Objectives.get_children():
		child.completed.connect(_on_Objective_completed)

func manual_progress_objective(p_idx):
	var instance = _a_Objectives.get_child(p_idx)
	instance.manual_progress()

func is_active():
	return _a_active

func get_objective_instances():
	return _a_Objectives.get_children()

func get_save_data():
	var data = {}
	data["Active"] = _a_active
	data["Completed_Objectives_Amount"] = _a_completed_objectives_amount
	data["Objectives"] = []
	for child in _a_Objectives.get_children():
		var child_data = child.get_save_data()
		data["Objectives"].push_back(child_data)
	
	return data

func load_file_data(p_data):
	_a_active = p_data["Active"]
	_a_completed_objectives_amount = p_data["Completed_Objectives_Amount"]
	for i in p_data["Objectives"].size():
		var child_data = p_data["Objectives"][i]
		var child = _a_Objectives.get_child(i)
		child.load_file_data(child_data)

func load_data_init():
	for child in _a_Objectives.get_children():
		child.load_data_init()

func _on_Objective_completed():
	_a_completed_objectives_amount += 1
	if _a_completed_objectives_amount == _a_Objectives.get_child_count():
		_a_active = false
		completed.emit()
