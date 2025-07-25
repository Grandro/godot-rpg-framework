extends "res://Global_Scenes/Debug/Scenes/Entry_List/Scripts/Entry_List.gd"

func instantiate_entry_(p_data, p_self_key = "", p_name = ""):
	var instance = instantiate_entry(p_name)
	instance.update_expression_self.call_deferred(p_self_key)
	instance.update_expression_instances.call_deferred()
	instance.load_expression_data.call_deferred(p_data)
	
	return instance

func instantiate_entry_from_data(p_data):
	var data = p_data["Expression"]
	var self_key = p_data["Expression_Self_Key"]
	var name_ = p_data["Name"]
	var instance = instantiate_entry_(data, self_key, name_)
	
	return instance

func _on_Add_pressed():
	var instance = instantiate_entry_({})
	add_entry(instance)
