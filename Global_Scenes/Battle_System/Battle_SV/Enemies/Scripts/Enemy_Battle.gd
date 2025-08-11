extends "res://Global_Scenes/Battle_System/Battle_SV/Character_Battle/Scripts/Character_Battle.gd"

signal action_reaction_started(p_target)
signal action_reaction_finished(p_target)

@export var _e_key : String = ""
@export var _e_select_offset: Vector3 = Vector3.ZERO

var _a_EXP = -1
var _a_loot = {} # [item_key][amount] = amount_in_pool

func _ready():
	super()
	_a_Actions.reaction_started.connect(_on_Actions_reaction_started)
	_a_Actions.reaction_finished.connect(_on_Actions_reaction_finished)

func _party_members_filtered(p_party_members):
	# Filter out dead party members
	var filtered = []
	for pm_key in p_party_members:
		var instance = p_party_members[pm_key]
		var HP = instance.comph().call_comp("Stats", "get_curr_stat", ["HP"])
		if HP > 0:
			filtered.push_back(pm_key)
	
	return filtered

func _pick_target():
	var party_members = _a_encounter.get_party_members()
	var filtered = _party_members_filtered(party_members)
	var target_key = filtered.pick_random()
	_a_target = party_members[target_key]

func get_key():
	return _e_key

func get_select_offset():
	return _e_select_offset

func set_EXP(p_EXP):
	_a_EXP = p_EXP

func get_EXP():
	return _a_EXP

func set_loot(p_loot):
	_a_loot = p_loot

func get_loot():
	return _a_loot

func _on_Actions_reaction_started():
	action_reaction_started.emit(_a_target)

func _on_Actions_reaction_finished():
	action_reaction_finished.emit(_a_target)
