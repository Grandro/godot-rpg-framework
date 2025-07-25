extends "res://Global_Scenes/Debug/Scenes/Entry_List/Scripts/Entry_List.gd"

var _a_keys_type = "" # Map/Global

func instantiate_entry_(p_loc_id, p_value, p_name = ""):
	var instance = instantiate_entry(p_name)
	if !_e_enumerate:
		var idx = _a_VBox.get_child_count()
		instance.set_select_text.call_deferred(str(idx))
	instance.set_loc_id_type.call_deferred(_a_keys_type)
	instance.set_loc_id.call_deferred(p_loc_id)
	instance.set_value.call_deferred(p_value)
	
	return instance

func instantiate_entry_from_data(p_data):
	var loc_id = p_data["Loc_ID"]["Loc_ID"]
	var value = p_data["Value"]
	var name_ = p_data["Name"]
	var instance = instantiate_entry_(loc_id, value, name_)
	
	return instance

func set_keys_type(p_keys_type):
	_a_keys_type = p_keys_type

func _on_Add_pressed():
	var instance = instantiate_entry_("", "")
	add_entry(instance)
