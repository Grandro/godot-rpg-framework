extends "res://Global_Scenes/Debug/Command_Editor/Entries/Scripts/Entry_Object.gd"

# Breakable: ["Anim_Keep_Dir"]["Value"]/["Anim_All"]["Value"], ["Object"]["Value"]
func _update_warnings_add():
	var instance = _update_warnings_add_object()
	if is_instance_valid(instance):
		var anim_list = instance.comph().call_comp("Anims", "get_animation_list")
		var keep_dir = _a_data["Keep_Dir"]["Value"]
		var anim_name = ""
		var type_key = ""
		if keep_dir:
			anim_name = _a_data["Anim_Keep_Dir"]["Value"]
			anim_name += "_%s" % instance.comph().call_comp("Movement", "get_dir")
			type_key = "Anim_Keep_Dir"
		else:
			anim_name = _a_data["Anim_All"]["Value"]
			type_key = "Anim_All"
		
		if !(anim_name in anim_list):
			var value_keys = [type_key, "Value"]
			var args = _Warning_Args_String.new(anim_name, value_keys)
			_a_warnings.push_back(args)

func _update_display_main_base_args():
	var object_text = _get_display_text(_a_data["Object"])
	var backwards = _a_data["Backwards"]["Value"]
	var wait_finish = _a_data["Wait_Finish"]["Value"]
	var speed_text = _get_display_text(_a_data["Speed"])
	var keep_dir = _a_data["Keep_Dir"]["Value"]
	var anim_text = ""
	if keep_dir:
		anim_text = _get_display_text(_a_data["Anim_Keep_Dir"])
	else:
		anim_text = _get_display_text(_a_data["Anim_All"])
	
	var text = object_text
	text += ", %s" % anim_text
	if backwards:
		text += ", %s" % tr("DEBUG_CUTSCENES_BACKWARDS")
	text += ", %s" % speed_text
	
	if wait_finish:
		text += " (%s)" % tr("WAIT")
	_a_Main.set_base_args(text)
