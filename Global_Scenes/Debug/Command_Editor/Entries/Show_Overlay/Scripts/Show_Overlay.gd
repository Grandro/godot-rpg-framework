extends "res://Global_Scenes/Debug/Command_Editor/Entries/Scripts/Entry_Command.gd"

const _a_TRANS_MASKS_PATH = "res://Global_Resources/Sprites/Overlays/Trans"

# Breakable: ["Mask"], ["Anim"]
func _update_warnings_add():
	var type = _a_data["Type"]
	match type:
		"Trans":
			var mask_path = _a_data["Mask"]
			if !FileAccess.file_exists(mask_path):
				var filters = PackedStringArray(["*.png"])
				var args = _Warning_Args_File.new(mask_path, ["Mask"], 
												_a_TRANS_MASKS_PATH, filters)
				_a_warnings.push_back(args)
			
			var anim = _a_data["Anim"]
			if !Global.has_trans_anim(anim):
				var args = _Warning_Args_String.new(anim, ["Anim"])
				_a_warnings.push_back(args)

func _update_display_main_base_args():
	var type = _a_data["Type"]["Value"]
	var mask_path = _a_data["Mask"]["Value"]
	var mask_file = mask_path.get_file()
	var anim_text = _get_display_text(_a_data["Anim"])
	
	var text = tr("DEBUG_CUTSCENES_%s" % type.to_upper())
	match type:
		"Trans":
			text += ", %s" % mask_file
	text += ", %s" % anim_text
	_a_Main.set_base_args(text)
