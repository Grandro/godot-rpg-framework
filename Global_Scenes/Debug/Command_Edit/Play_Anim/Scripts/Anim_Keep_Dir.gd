extends "res://Global_Scenes/Debug/Scenes/Value_Select/Scripts/Value_Options.gd"

const _a_DIRS = ["Down", "Left", "Right", "Up"]

var _a_cut_anims = {} # Match anims to cut_anim

func update_options():
	_clear_options()
	
	var anims = {}
	for anim in _e_options:
		var cut_anim = anim.substr(0, anim.rfind("_"))
		var has_dir = false
		for dir in _a_DIRS:
			if "_" + dir in anim:
				has_dir = true
				if !anims.has(cut_anim):
					anims[cut_anim] = {}
				anims[cut_anim][dir] = anim
		
		if has_dir:
			_a_cut_anims[anims[cut_anim]] = cut_anim
	
	var keys = anims.keys()
	for i in keys.size():
		var key = keys[i]
		_a_option_idxs[key] = i
		_a_Value.add_item(key)
		_a_Value.set_item_metadata(i, anims[key])

func get_save_data():
	var data = super()
	var anims = get_selected_key()
	if anims == null:
		data["Value"] = null
	else:
		data["Value"] = _a_cut_anims[anims]
	
	return data
