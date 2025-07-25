extends "res://Global_Scenes/Debug/Scenes/Entry_List/Scripts/Entry_List.gd"

signal entry_key_changed(p_key, p_instance)

func instantiate_entry_(p_key):
	var instance = instantiate_entry(p_key)
	instance.key_changed.connect(_on_Entry_key_changed.bind(instance))
	instance.set_key(p_key)
	
	return instance

func get_entries_keys():
	var keys = []
	for child in _a_VBox.get_children():
		var key = child.get_key()
		keys.push_back(key)
	
	return keys

func _on_Entry_key_changed(p_key, p_instance):
	p_instance.set_change_key_text("")
	entry_key_changed.emit(p_key, p_instance)
