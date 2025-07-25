extends Resource

const _a_NAME_LOC_ID = "SV_ACTIONS_%s_NAME"
const _a_DESC_LOC_ID = "SV_ACTIONS_%s_DESC"

@export var _e_key: String = ""
@export_enum("None", "Ally", "Enemy") var _e_target_type: String = "None"
@export var _e_target_amount: int = -1
@export var _e_ATK_scaling: float = 0.0
@export var _e_MAG_scaling: float = 0.0
@export var _e_SP_cost : int = -1

func get_key():
	return _e_key

func get_name_():
	var key_upper = _e_key.to_upper()
	var name_ = tr(_a_NAME_LOC_ID % key_upper)
	
	return name_

func get_desc():
	var key_upper = _e_key.to_upper()
	var desc = tr(_a_DESC_LOC_ID % key_upper)
	
	return desc

func get_target_type():
	return _e_target_type

func get_target_amount():
	return _e_target_amount

func get_SP_cost():
	return _e_SP_cost
