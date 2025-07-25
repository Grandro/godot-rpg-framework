extends "res://Global_Scenes/Debug/Command_Editor/Entries/Scripts/Entry_Branch.gd"

# Breakable: 
func _ready():
	super()
	_a_Main.set_collapse_visible(true)

func add_res_data(p_res_data, p_args = []):
	# Iterate n times over the entries and collect res_data
	var start = _a_data["Args"]["Start"]["Value"]
	var end = _a_data["Args"]["End"]["Value"]
	var step = _a_data["Args"]["Step"]["Value"]
	var iters = int(floor(end - start) / step) + 1
	
	if iters > 0:
		# Terminating
		var end_idx = -1
		if !p_args.is_empty():
			end_idx = p_args[1]
		
		var entries = get_entries(0)
		for i in iters:
			for j in entries.size():
				if i == iters - 1 && j == end_idx:
					break
				
				var entry = entries[j]
				entry.add_res_data(p_res_data)
	else:
		# Not terminating -> Print warning
		push_warning("Loop doesn't terminate.")

func _update_display_main_base_args():
	var option_key = _a_data["Key"]
	var args = _a_data["Args"]
	
	var text = ""
	match option_key:
		"For":
			var idx_text = _get_display_text(args["Idx"])
			var start_text = _get_display_text(args["Start"])
			var end_text = _get_display_text(args["End"])
			var step_text = _get_display_text(args["Step"])
			text += "%s = %s" % [idx_text, start_text]
			text += ", %s: %s" % [tr("DEBUG_CUTSCENES_END"), end_text]
			text += ", %s: %s" % [tr("DEBUG_CUTSCENES_STEP"), step_text]
	_a_Main.set_base_args(text)

func _update_branches():
	var margin = _get_main_arg_margin()
	_a_Main.set_collapse_visible(true)
	_a_End.set_left_margin(margin)

func get_cutscene_data():
	return get_save_data()
