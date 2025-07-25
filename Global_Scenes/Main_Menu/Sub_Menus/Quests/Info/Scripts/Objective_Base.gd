extends HBoxContainer

@onready var _a_Desc = get_node("HBox/Desc")

var _a_objective_instance = null

func _ready():
	_a_objective_instance.progressed.connect(_on_Objective_progressed)
	
	var data = _a_objective_instance.get_data()
	var desc = data.get_desc()
	var value = _a_objective_instance.get_value()
	_a_Desc.set_text(desc)
	_set_progress_curr(value)

func set_objective_instance(p_objective_instance):
	_a_objective_instance = p_objective_instance

func _set_progress_curr(_p_value):
	pass

func _on_Objective_progressed():
	var value = _a_objective_instance.get_value()
	_set_progress_curr(value)
