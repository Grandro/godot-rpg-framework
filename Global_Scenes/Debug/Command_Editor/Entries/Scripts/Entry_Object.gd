extends "res://Global_Scenes/Debug/Command_Editor/Entries/Scripts/Entry_Command.gd"

func add_res_data(p_res_data, _p_args = []):
	var key = _a_data["Object"]["Value"]
	if !p_res_data["Objects"].has(key):
		p_res_data["Objects"][key] = {}
		p_res_data["Objects"][key]["Properties"] = {}
		p_res_data["Objects"][key]["Equipables"] = {}
	
	# Collect changed properties of objects
	var res_properties = p_res_data["Objects"][key]["Properties"]
	var properties = _a_data["Object"]["Properties"]
	for comp_key in properties:
		if !res_properties.has(comp_key):
			res_properties[comp_key] = {}
		for property in properties[comp_key]:
			res_properties[comp_key][property] = properties[comp_key][property]
	
	# Collect changed equipables of objects
	var res_equipables = p_res_data["Objects"][key]["Equipables"]
	var equipables = _a_data["Object"]["Equipables"]
	for group in equipables:
		res_equipables[group] = equipables[group]

# Breakable: ["Object"]["Value"]
func _update_warnings_add():
	_update_warnings_add_object()

func _update_warnings_add_object():
	var object_key = _a_data["Object"]["Value"]
	var global_si = Global.get_singleton(self, "Global")
	var instance = global_si.get_object(object_key)
	if instance == null:
		var value_keys = ["Object", "Value"]
		var args = _Warning_Args_String.new(object_key, value_keys)
		_a_warnings.push_back(args)
	
	return instance
