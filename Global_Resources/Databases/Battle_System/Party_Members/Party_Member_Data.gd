extends Resource

@export var _e_stats: StatsData = null
@export var _e_actions: Dictionary = {"Commands": {}, "Specials": {}}

func get_stats():
	return _e_stats

func get_commands():
	return _e_actions["Commands"]

func get_specials():
	return _e_actions["Specials"]

func get_exp_till_next_lvl(p_lvl):
	return int(5 * pow(p_lvl, 1.5))
