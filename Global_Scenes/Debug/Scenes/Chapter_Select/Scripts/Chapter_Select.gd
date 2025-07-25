extends "res://Global_Scenes/Debug/Scenes/Value_Select/Scripts/Value_Options.gd"

func update_options():
	_clear_options()
	
	var chapters = Progress.get_chapters()
	for i in chapters.size():
		var chapter = chapters[i]
		_a_option_idxs[chapter] = i
		_a_Value.add_item(chapter)
		_a_Value.set_item_metadata(i, chapter)
