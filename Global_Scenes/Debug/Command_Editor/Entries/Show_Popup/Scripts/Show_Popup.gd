extends "res://Global_Scenes/Debug/Command_Editor/Entries/Scripts/Entry_Object.gd"

# Breakable: ["Type"]["Value"]
func _update_warnings_add():
	super()
	
	var popup_types = Global.get_popup_types()
	var type = _a_data["Type"]["Value"]
	if !popup_types.has(type):
		var value_keys = ["Type", "Value"]
		var args = _Warning_Args_String.new(type, value_keys)
		_a_warnings.push_back(args)

func _update_display_main_base_args():
	var object_text = _get_display_text(_a_data["Object"])
	var type_text = _get_display_text(_a_data["Type"])
	var wait_finish = _a_data["Wait_Finish"]["Value"]
	
	var text = object_text
	text += ", %s" % type_text
	if wait_finish:
		text += " (%s)" % tr("WAIT")
	_a_Main.set_base_args(text)
