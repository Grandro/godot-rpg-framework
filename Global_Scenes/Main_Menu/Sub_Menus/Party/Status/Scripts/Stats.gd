extends VBoxContainer

var _a_key = "" # Party_Member key
var _a_stats = {} # Match key to instance

func _ready():
	for child in get_children():
		var key = child.get_key()
		var max_key = child.get_max_key()
		_a_stats[key] = child
		if !max_key.is_empty():
			_a_stats[max_key] = child
	
	var global_si = Global.get_singleton(self, "Global")
	global_si.pm_stat_changed.connect(_on_Global_pm_stat_changed)

func open(p_key, p_stats):
	_a_key = p_key
	
	for stat in p_stats:
		var instance = _a_stats[stat]
		var value = p_stats[stat]
		instance.set_curr_value(value)
		
		var max_key = instance.get_max_key()
		if !max_key.is_empty():
			var max_value = p_stats[max_key]
			instance.set_max_value(max_value)
		else:
			instance.hide_max_value()

func _on_Global_pm_stat_changed(p_key, p_stat, p_value):
	if p_key != _a_key:
		return
	
	var instance = _a_stats[p_stat]
	if p_stat.begins_with("Max"):
		instance.set_max_value(p_value)
	else:
		instance.set_curr_value(p_value)
