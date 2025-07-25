extends "res://Scenes/Custom_Containers/Entry_Toggler/Scripts/Entry_Toggler.gd"

var _a_entries = {} # Match key to instance

func instantiate_entry_(p_select_text, p_texture, p_key):
	var instance = instantiate_entry(p_select_text, p_texture)
	instance.set_key(p_key)
	
	_a_entries[p_key] = instance
	
	return instance

func toggle(p_key):
	var instance = _a_entries[p_key]
	_toggle(instance)
