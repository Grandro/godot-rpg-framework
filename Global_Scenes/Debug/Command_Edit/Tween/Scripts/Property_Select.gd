extends "res://Global_Scenes/Debug/Scenes/Value_Select/Scripts/Value_Options.gd"

var _a_object = null
var _a_comp = ""

func update_options():
	super()
	
	var instance = _a_object.comph().get_comp(_a_comp)
	var i = 0
	for args in instance.get_property_list():
		var usage = args["usage"]
		if !Debug.is_usage_for_editor(usage):
			continue
		
		var property = args["name"]
		var curr_value = instance.get(property)
		var type = typeof(curr_value)
		if !Debug.is_type_tween_supported(type):
			continue
		
		_a_option_idxs[property] = i
		_a_Value.add_item(property)
		_a_Value.set_item_metadata(i, property)
		
		i += 1

func set_object(p_object):
	_a_object = p_object

func set_comp(p_comp):
	_a_comp = p_comp
