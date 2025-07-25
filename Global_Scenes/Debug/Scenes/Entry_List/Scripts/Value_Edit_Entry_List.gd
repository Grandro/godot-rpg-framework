extends "res://Global_Scenes/Debug/Scenes/Entry_List/Scripts/Entry_List.gd"

@export var _e_value_editable: bool = false

func instantiate_entry_(p_value = "", p_name = ""):
	var instance = instantiate_entry(p_name)
	instance.set_value_editable.call_deferred(_e_value_editable)
	instance.set_value.call_deferred(p_value)
	
	return instance

func instantiate_entry_from_data(p_data):
	var value = p_data["Value"]
	var name_ = p_data["Name"]
	var instance = instantiate_entry_(value, name_)
	
	return instance

func set_value_editable(p_value_editable):
	_e_value_editable = p_value_editable
	for child in _a_VBox.get_children():
		child.set_value_editable(p_value_editable)

func _on_Add_pressed():
	var instance = instantiate_entry_()
	add_entry(instance)
