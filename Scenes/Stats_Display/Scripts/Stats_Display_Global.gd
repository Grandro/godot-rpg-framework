extends "res://Scenes/Stats_Display/Scripts/Stats_Display_Base.gd"

func _ready():
	super()
	var global_si = Global.get_singleton(self, "Global")
	global_si.pm_stat_changed.connect(_on_pm_stat_changed)
	
	_instantiate_entries()

func _instantiate_entries():
	var global_si = Global.get_singleton(self, "Global")
	var party_members = global_si.get_party_members_active()
	
	for key in party_members:
		var args = party_members[key]
		var stats = args["Stats"]
		var scene = load(_a_ENTRY_SCENE_PATH % key)
		var instance = scene.instantiate()
		for stat in _e_visible_stats:
			var value = stats[stat]
			_set_entry_stat(instance, stat, value, false)
		
		_a_entries[key] = instance
		_a_Entries.add_child(instance)

func _on_pm_stat_changed(p_key, p_stat, p_value):
	if !_e_visible_stats.has(p_stat):
		return
	
	var instance = _a_entries[p_key]
	_set_entry_stat(instance, p_stat, p_value, true)
