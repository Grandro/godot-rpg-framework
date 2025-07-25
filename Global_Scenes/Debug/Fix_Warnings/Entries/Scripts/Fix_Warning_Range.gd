extends "res://Global_Scenes/Debug/Fix_Warnings/Entries/Scripts/Fix_Warning_Base.gd"

@onready var _a_Range = get_node("VBox/New/Range")

var _a_min_value = null # New min value
var _a_max_value = null # New max value

func _ready():
	super()
	_a_Range.min_value_changed.connect(_on_Range_min_value_changed)
	_a_Range.max_value_changed.connect(_on_Range_max_value_changed)
	
	var curr_min_value = _a_Range.get_curr_min_value()
	var curr_max_value = _a_Range.get_curr_max_value()
	var min_ = _a_warning.get_min()
	var max_ = _a_warning.get_max()
	_a_Range.set_min_min(min_)
	_a_Range.set_min_max(curr_max_value)
	_a_Range.set_max_min(curr_min_value)
	_a_Range.set_max_max(max_)

func apply_changes():
	if _a_min_value == null || _a_max_value == null:
		return
	
	var value_keys = _a_warning.get_value_keys()
	for i in value_keys.size():
		var args = value_keys[i]
		var last = args[-1]
		var dic = _a_data
		for j in args.size() - 1:
			var key = args[j]
			dic = dic[key]
		
		match i:
			0: dic[last] = _a_min_value
			1: dic[last] = _a_max_value

func _on_Range_min_value_changed(p_value):
	_a_min_value = p_value

func _on_Range_max_value_changed(p_value):
	_a_max_value = p_value
