extends "res://Global_Scenes/Battle_System/Battle_SV/Scripts/Character_Battle.gd"

signal hit(p_instance, p_target)
signal attack_pm_started(p_target)
signal attack_pm_finished(p_target)

@export var _e_select_offset: Vector3 = Vector3.ZERO

var _a_EXP = -1
var _a_loot = {} # [item_key][amount] = amount_in_pool

func _ready():
	super()
	_a_Hitbox.body_entered.connect(_on_Hitbox_body_entered)

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

func _on_Hitbox_body_entered(p_body):
	hit.emit(self, p_body)
