extends "res://Global_Scenes/Debug/Command_Editor/Entries/Scripts/Entry_Object.gd"

# Breakable: ["Audio"]["Value"]
func _update_warnings_add():
	super()
	
	var stream_path = _a_data["Audio"]["Value"]
	if !FileAccess.file_exists(stream_path):
		var value_keys = ["Audio", "Value"]
		var dir_path = "res://Global_Resources/Audio"
		var filters = PackedStringArray(["*.ogg", "*.wav"])
		var args = _Warning_Args_File.new(stream_path, value_keys, dir_path, filters)
		_a_warnings.push_back(args)

func _update_display_main_base_args():
	var audio_type = _get_display_text(_a_data["Audio_Type"])
	var type = _get_display_text(_a_data["Type"])
	var stream_path = _a_data["Audio"]["Value"]
	var wait_finish = _a_data["Wait_Finish"]["Value"]
	
	var text = audio_type
	text += ", %s" % type
	if !stream_path.is_empty():
		var file_name = stream_path.get_file()
		text += ", %s" % file_name
	else:
		text += ", -"
	
	if wait_finish:
		text += " (%s)" % tr("WAIT")
	_a_Main.set_base_args(text)
