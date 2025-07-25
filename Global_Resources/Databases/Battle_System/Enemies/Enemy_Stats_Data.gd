extends StatsData

@export var _e_EXP : int = -1
@export var _e_loot : Dictionary = {} # [item_key][amount] = amount_in_pool

func get_EXP():
	return _e_EXP

func get_loot():
	return _e_loot
