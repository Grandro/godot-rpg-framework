extends "res://Global_Scenes/Debug/Command_Editor/Entries/Scripts/Entry_Object.gd"

@export var _e_loc_id: String = ""

# Breakable: ["Object"]["Value"], ["Idx"]["Value"]
func _update_warnings_add():
	var instance = _update_warnings_add_object()
	if is_instance_valid(instance):
		var interactions_comp = instance.comph().get_comp("Interactions")
		var interaction_count = interactions_comp.get_child_count()
		var idx = _a_data["Idx"]["Value"]
		if idx >= interaction_count:
			var value_keys = ["Idx", "Value"]
			var args = _Warning_Args_Int.new(idx, value_keys, 0, interaction_count - 1)
			_a_warnings.push_back(args)

func _update_display_main_base_desc():
	_a_Main.set_base_desc("%s:" % tr(_e_loc_id))

func _update_display_main_base_args():
	var object_text = _get_display_text(_a_data["Object"])
	var type_text = _get_display_text(_a_data["Type"])
	var idx_text = _get_display_text(_a_data["Idx"])
	var value_text = _get_display_text(_a_data["Value"])
	
	var text = object_text
	text += ", %s" % type_text
	text += ", %s" % idx_text
	text += ", %s" % value_text
	_a_Main.set_base_args(text)
