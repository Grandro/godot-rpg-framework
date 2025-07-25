extends "res://Global_Scenes/Debug/Scenes/Entry_List/Scripts/Entry_List.gd"

signal entry_type_changing()
signal entry_type_changed(p_instance)

@export var _e_types : Array[String] = []

func instantiate_entry_(p_type = "", p_data = {}, p_name = ""):
	var instance = instantiate_entry(p_name)
	if p_data.is_empty():
		p_data = _get_empty_data()
	
	instance.type_changing.connect(_on_Entry_type_changing)
	instance.type_changed.connect(_on_Entry_type_changed.bind(instance))
	instance.set_data(p_data)
	instance.set_types.call_deferred(_e_types)
	if !p_type.is_empty():
		instance.select_type.call_deferred(p_type)
	
	return instance

func instantiate_entry_from_data(p_data):
	var type = p_data["Type"]
	var data = p_data["Data"]
	var name_ = p_data["Name"]
	var instance = instantiate_entry_(type, data, name_)
	
	return instance

func _get_empty_data():
	var data = {}
	for type in _e_types:
		data[type] = {}
	
	return data

func _on_Add_pressed():
	var instance = instantiate_entry_()
	add_entry(instance)

func _on_Entry_type_changing():
	entry_type_changing.emit()

func _on_Entry_type_changed(p_instance):
	entry_type_changed.emit(p_instance)
