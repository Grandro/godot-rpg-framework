extends Resource

const _a_NAME_LOC_ID = "ENEMY_%s_NAME"
const _a_DESC_LOC_ID = "ENEMY_%s_DESC"

@export var _e_key: String = ""
@export var _e_stats: StatsData = null
@export var _e_actions: Dictionary = {"Commands": [], "Specials": []}

func get_name_():
	var key_upper = _e_key.to_upper()
	var name_ = tr(_a_NAME_LOC_ID % key_upper)
	
	return name_

func get_desc():
	var key_upper = _e_key.to_upper()
	var desc = tr(_a_DESC_LOC_ID % key_upper)
	
	return desc

func get_stats():
	return _e_stats

func get_actions():
	return _e_actions
