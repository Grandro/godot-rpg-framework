extends "res://Global_Scenes/Debug/Command_Editor/Entries/Scripts/Entry_Object.gd"

func add_res_data(p_res_data, p_args = []):
	super(p_res_data, p_args)
	
	var end_object_key = "$Free_Camera"
	var type = _a_data["Type"]["Value"]
	if type == "Object_To_Object":
		var change_camera = _a_data["Change_Camera"]["Value"]
		if change_camera:
			end_object_key = _a_data["End_Object"]["Value"]
	p_res_data["$Free_Camera"]["Object"] = end_object_key

# Breakable: ["Start_Object"]["Value"], ["End_Object"]["Value"]
func _update_warnings_add():
	super()
	
	var global_si = Global.get_singleton(self, "Global")
	var start_object_key = _a_data["Start_Object"]["Value"]
	var start_instance = global_si.get_object(start_object_key)
	if !is_instance_valid(start_instance):
		var value_keys = ["Start_Object", "Value"]
		var args = _Warning_Args_String.new(start_object_key, value_keys)
		_a_warnings.push_back(args)
	
	var end_object_key = _a_data["End_Object"]["Value"]
	var end_instance = global_si.get_object(end_object_key)
	if !is_instance_valid(end_instance):
		var value_keys = ["End_Object", "Value"]
		var args = _Warning_Args_String.new(end_object_key, value_keys)
		_a_warnings.push_back(args)

func _update_display_main_base_args():
	var type = _a_data["Type"]["Value"]
	var interpolate = _a_data["Interpolate"]["Value"]
	
	var text = ""
	match type:
		"Move_Route":
			if interpolate:
				var speed_text = _get_display_text(_a_data["Speed"])
				var trans_type_text = _get_display_text(_a_data["Trans_Type"])
				var ease_type_text = _get_display_text(_a_data["Ease_Type"])
				var wait_finish = _a_data["Wait_Finish"]["Value"]
				text += "%s" % speed_text
				text += ", %s" % trans_type_text
				text += ", %s" % ease_type_text
				if wait_finish:
					text += " (%s)" % tr("WAIT")
			else:
				var nav_mesh_path_points = _a_data["Gen_Path"]["Nav_Mesh_Path_Points"]
				if nav_mesh_path_points.is_empty():
					text += "-"
				else:
					var point = nav_mesh_path_points[-1]
					text += str(point)
		
		"Object_To_Object":
			var end_object_text = _get_display_text(_a_data["End_Object"])
			if interpolate:
				var start_object_text = _get_display_text(_a_data["Start_Object"])
				var speed_text = _get_display_text(_a_data["Speed"])
				var trans_type_text = _get_display_text(_a_data["Trans_Type"])
				var ease_type_text = _get_display_text(_a_data["Ease_Type"])
				var wait_finish = _a_data["Wait_Finish"]["Value"]
				text += "%s - %s" % [start_object_text, end_object_text]
				text += ", %s" % speed_text
				text += ", %s" % trans_type_text
				text += ", %s" % ease_type_text
				if wait_finish:
					text += " (%s)" % tr("WAIT")
			else:
				text += end_object_text
		
		"Object_To_Point":
			var point_selected = _a_data["Point"]["Selected"]
			if interpolate:
				var start_object_text = _get_display_text(_a_data["Start_Object"])
				text += "%s - " % start_object_text
			
			if point_selected:
				var point_text = _get_display_text(_a_data["Point"])
				text += str(point_text)
			else:
				text += "-"
			
			if interpolate:
				var speed_text = _get_display_text(_a_data["Speed"])
				var trans_type_text = _get_display_text(_a_data["Trans_Type"])
				var ease_type_text = _get_display_text(_a_data["Ease_Type"])
				var wait_finish = _a_data["Wait_Finish"]["Value"]
				text += ", %s" % speed_text
				text += ", %s" % trans_type_text
				text += ", %s" % ease_type_text
				if wait_finish:
					text += " (%s)" % tr("WAIT")
	_a_Main.set_base_args(text)

func _update_display_main_args():
	super()
	
	var type = _a_data["Type"]["Value"]
	var interpolate = _a_data["Interpolate"]["Value"]
	match type:
		"Move_Route":
			if interpolate:
				var nav_mesh_path_points = _a_data["Gen_Path"]["Nav_Mesh_Path_Points"]
				for nav_mesh_path_point in nav_mesh_path_points:
					_instantiate_main_arg(str(nav_mesh_path_point), _e_color)
