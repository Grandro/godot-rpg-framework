extends "res://Scenes/Stats_Display/Scripts/Stats_Display_Base.gd"

func open(p_instances):
	for instance in p_instances:
		var key = instance.comph().call_comp("Reference", "get_key")
		var stats_comp = instance.comph().get_comp("Stats")
		stats_comp.stat_changed.connect(_on_pm_stat_changed.bind(key))
		var entry_scene = load(_a_ENTRY_SCENE_PATH % key)
		var entry_instance = entry_scene.instantiate()
		for stat in _e_visible_stats:
			var value = _get_pm_stat(instance, stat)
			_set_entry_stat(entry_instance, stat, value, false)
		
		_a_entries[key] = entry_instance
		_a_Entries.add_child(entry_instance)

func _get_pm_stat(p_instance, p_stat):
	if p_stat.begins_with("Max_"):
		var stat = p_stat.trim_prefix("Max_")
		return p_instance.comph().call_comp("Stats", "get_max_stat", [stat])
	else:
		return p_instance.comph().call_comp("Stats", "get_curr_stat", [p_stat])

func _on_pm_stat_changed(p_stat, p_value, p_key):
	if !_e_visible_stats.has(p_stat):
		return
	
	var instance = _a_entries[p_key]
	_set_entry_stat(instance, p_stat, p_value, true)
