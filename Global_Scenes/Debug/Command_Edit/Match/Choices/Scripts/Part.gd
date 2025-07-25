extends "res://Global_Scenes/Debug/Scenes/Value_Select/Scripts/Value_Options.gd"

var _a_key_type = "" # Map/Global
var _a_chapter = ""
var _a_location = ""
var _a_dialogue_key = ""

func update_options():
	_clear_options()
	if _a_dialogue_key.is_empty():
		return
	
	var dialogues_data = Databases.get_global_map_data("Dialogues", _a_key_type, _a_chapter, _a_location)
	var i = 0
	for entry_key in dialogues_data[_a_dialogue_key]["Data"]:
		var args = dialogues_data[_a_dialogue_key]["Data"][entry_key]
		var part_idx = int(entry_key)
		var type = args["Type"]
		var has_choice = false
		match type:
			"Text":
				var text_data = args["Data"]["Text"]
				var choice_entries = text_data["Choice"]["Entries"]
				has_choice = !choice_entries.is_empty()
			
			"Choice":
				has_choice = true
		
		if has_choice:
			_a_Value.add_item(entry_key)
			_a_Value.set_item_metadata(i, part_idx)
			_a_option_idxs[part_idx] = i
			i += 1

func set_key_type(p_key_type):
	_a_key_type = p_key_type

func set_chapter(p_chapter):
	_a_chapter = p_chapter

func set_location(p_location):
	_a_location = p_location

func set_dialogue_key(p_dialogue_key):
	_a_dialogue_key = p_dialogue_key
