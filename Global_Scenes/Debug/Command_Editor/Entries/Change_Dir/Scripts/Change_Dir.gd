extends "res://Global_Scenes/Debug/Command_Editor/Entries/Scripts/Entry_Object.gd"

# Breakable: Look_At: Object: ["Args"]["Object"]["Value"]
#			 Look_Away: Object: ["Args"]["Object"]["Value"]
func _update_warnings_add():
	super()
	
	var type = _a_data["Type"]["Value"]
	if type == "Look_At" || type == "Look_Away":
		var look_type = _a_data["Args"]["Type"]["Value"]
		if look_type == "Object":
			var object_key = _a_data["Args"]["Object"]["Value"]
			var global_si = Global.get_singleton(self, "Global")
			var instance = global_si.get_object(object_key)
			if !is_instance_valid(instance):
				var value_keys = ["Args", "Object", "Value"]
				var args = _Warning_Args_String.new(object_key, value_keys)
				_a_warnings.push_back(args)

func _update_display_main_base_args():
	var object_text = _get_display_text(_a_data["Object"])
	var type = _a_data["Type"]["Value"]
	var args_text = " "
	match type:
		"Fixed_Dir":
			var dir = _get_display_text(_a_data["Args"]["Dir"])
			args_text += "(%s)" % dir
		
		"Look_Degrees":
			var degrees = _get_display_text(_a_data["Args"]["Degrees"])
			args_text += "(%s°)" % degrees
		
		_:  # Look_At, Look_Away
			var arg_text = ""
			var look_type = _a_data["Args"]["Type"]["Value"]
			match look_type:
				"Object":
					arg_text = _get_display_text(_a_data["Args"]["Object"])
				"Point":
					var selected = _a_data["Args"]["Point"]["Selected"]
					if selected:
						arg_text = _get_display_text(_a_data["Args"]["Point"])
					else:
						arg_text = "-"
			
			var loc_id = "DEBUG_CUTSCENES_%s" % look_type.to_upper()
			args_text += "(%s, %s)" % [tr(loc_id), arg_text]
	
	var loc_id = "DEBUG_CUTSCENES_TYPE_%s" % type.to_upper()
	var text = object_text
	text += ", %s" % tr(loc_id)
	text += args_text
	_a_Main.set_base_args(text)
