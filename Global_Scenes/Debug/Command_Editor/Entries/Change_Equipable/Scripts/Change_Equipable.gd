extends "res://Global_Scenes/Debug/Command_Editor/Entries/Scripts/Entry_Object.gd"

# Breakable: ["Equipable"]["Value"]
func _update_warnings_add():
	super()
	_update_warnings_add_equipable()

func _update_warnings_add_equipable():
	var type = _a_data["Type"]["Value"]
	if type == "Unequip":
		return
	
	var global_si = Global.get_singleton(self, "Global")
	var object_key = _a_data["Object"]["Value"]
	var instance = global_si.get_object(object_key)
	if !is_instance_valid(instance):
		return
	
	var equipable_group = _a_data["Equipable_Group"]["Value"]
	var equipable_key = _a_data["Equipable"]["Value"]
	var equipable_scenes = instance.comph().call_comp("Equipment", "get_scenes")
	if !equipable_scenes[equipable_group].has(equipable_key):
		var value_keys = ["Equipable", "Value"]
		var args = _Warning_Args_String.new(equipable_key, value_keys)
		_a_warnings.push_back(args)

func _update_display_main_base_args():
	var object_text = _get_display_text(_a_data["Object"])
	var type_text = _get_display_text(_a_data["Type"])
	var equipable_group_text = _get_display_text(_a_data["Equipable_Group"])
	var equipable_key_text = _get_display_text(_a_data["Equipable"])
	
	var text = "%s, " % object_text
	text += "%s, " % type_text
	text += "%s, " % equipable_group_text
	text += "%s" % equipable_key_text
	_a_Main.set_base_args(text)
