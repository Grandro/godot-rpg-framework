extends "res://Global_Scenes/Debug/Command_Edit/Scripts/Menu_Base.gd"

signal branches_values_changed()

@export var _e_branches_editable : bool = true

var _a_branches_values = []

func is_branches_editable():
	return _e_branches_editable

func set_branches_values(p_branches_values):
	_a_branches_values = p_branches_values

func get_branches_values():
	return _a_branches_values

func get_save_data():
	var data = {}
	data["Branches_Values"] = _a_branches_values
	
	return data

func _load_data(p_data):
	_a_branches_values = p_data["Branches_Values"]
