extends Node

const a_DAMAGE_COLOR = Color8(255, 0, 0)
const a_HEAL_COLOR = Color8(0, 255, 0)

@onready var _a_Battle_SV = get_node("Battle_SV")

func get_battle_sv():
	return _a_Battle_SV
