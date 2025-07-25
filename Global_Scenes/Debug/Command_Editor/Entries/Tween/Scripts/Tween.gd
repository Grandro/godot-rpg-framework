extends "res://Global_Scenes/Debug/Command_Editor/Entries/Scripts/Entry_Object.gd"

# Breakable: ["Object"]["Value"], ["Comp"]["Value"], ["Property"]["Value"]
func _update_warnings_add():
	var object = _update_warnings_add_object()
	if is_instance_valid(object):
		var comp = _a_data["Comp"]["Value"]
		if !object.comph().has_comp(comp):
			var value_keys = ["Comp", "Value"]
			var args = _Warning_Args_String.new(comp, value_keys)
			_a_warnings.push_back(args)
		else:
			var property = _a_data["Property"]["Value"]
			var instance = object.comph().get_comp(comp)
			if !(property in instance):
				var value_keys = ["Property", "Value"]
				var args = _Warning_Args_String.new(property, value_keys)
				_a_warnings.push_back(args)

func _update_display_main_base_args():
	var object_text = _get_display_text(_a_data["Object"])
	var comp_text = _get_display_text(_a_data["Comp"])
	var property_text = _get_display_text(_a_data["Property"])
	var interpolate = _a_data["Interpolate"]["Value"]
	var end_value_text = _get_display_text(_a_data["End_Value"])
	
	var text = object_text
	text += ": %s: %s" % [comp_text, property_text]
	if interpolate:
		var start_value_text = _get_display_text(_a_data["Start_Value"])
		var duration_text = _get_display_text(_a_data["Duration"])
		var wait_finish = _a_data["Wait_Finish"]["Value"]
		
		text += ", %s - %s" % [start_value_text, end_value_text]
		text += ", %s" % str(duration_text)
		if wait_finish:
			text += " (%s)" % tr("WAIT")
	else:
		text += ", %s" % end_value_text
	_a_Main.set_base_args(text)
