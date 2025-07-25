extends "res://Global_Scenes/Debug/Scenes/Entry_List/Scripts/Entry_List.gd"

signal entry_preview_pressed(p_cutscene_data)
signal entry_option_test_selected(p_cutscene_data, p_skip_idxs)
signal entry_selectable_focus_entered(p_instance)

func instantiate_entry_(p_data = {}, p_name = ""):
	var instance = instantiate_entry(p_name)
	instance.preview_pressed.connect(_on_Entry_preview_pressed)
	instance.option_test_selected.connect(_on_Entry_option_test_selected)
	instance.selectable_focus_entered.connect(_on_Entry_selectable_focus_entered.bind(instance))
	instance.update_entries.call_deferred(p_data)
	
	return instance

func instantiate_entry_from_data(p_data):
	var data = p_data["Editor"]
	var name_ = p_data["Name"]
	var instance = instantiate_entry_(data, name_)
	
	return instance

func _on_Entry_preview_pressed(p_cutscene_data):
	entry_preview_pressed.emit(p_cutscene_data)

func _on_Entry_option_test_selected(p_cutscene_data, p_skip_idxs):
	entry_option_test_selected.emit(p_cutscene_data, p_skip_idxs)

func _on_Entry_selectable_focus_entered(p_instance):
	entry_selectable_focus_entered.emit(p_instance)

func _on_Add_pressed():
	var instance = instantiate_entry_({})
	add_entry(instance)
