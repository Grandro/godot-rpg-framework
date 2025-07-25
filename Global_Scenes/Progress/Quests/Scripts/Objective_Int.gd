extends "res://Global_Scenes/Progress/Quests/Scripts/Objective_Base.gd"

func manual_progress():
	_a_value += 1
	progressed.emit()
	
	var target_value = _e_data.get_target_value()
	if _a_value == target_value:
		_completed()

func _completed():
	_a_active = false
	completed.emit()

func get_save_data():
	var data = super()
	data["Value"] = _a_value
	
	return data

func load_file_data(p_data):
	super(p_data)
	_a_value = p_data["Value"]

func load_data_init():
	_a_value = 0
