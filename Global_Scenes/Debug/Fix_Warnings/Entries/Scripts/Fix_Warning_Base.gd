extends HBoxContainer

@onready var _a_Value_Keys = get_node("Value_Keys")
@onready var _a_Old_Desc = get_node("VBox/Old/Desc")
@onready var _a_Old_Value = get_node("VBox/Old/Value")
@onready var _a_New_Desc = get_node("VBox/New/Desc")

var _a_data = {} # Data of entry instance
var _a_warning = null # Warning instance
var _a_new_value = null # New value to apply

func _ready():
	var value_keys = _a_warning.get_value_keys()
	var value = _a_warning.get_value()
	_a_Value_Keys.set_text(str(value_keys))
	_a_Old_Value.set_text(str(value))

func apply_changes():
	if _a_new_value == null:
		return
	
	var value_keys = _a_warning.get_value_keys()
	var last = value_keys[-1]
	var dic = _a_data
	for i in value_keys.size() - 1:
		var key = value_keys[i]
		dic = dic[key]
	dic[last] = _a_new_value

func set_data(p_data):
	_a_data = p_data

func set_warning(p_warning):
	_a_warning = p_warning
