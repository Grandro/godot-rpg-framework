extends StatusEffect
class_name StatusEffectStat

@export_enum("HP", "SP", "ATK", "MAG", "DEF", "SPEED", "LUCK") var _e_stat : String = "HP"
@export var _e_mult : float = 1.0
@export var _e_add : float = 0.0

func activate(p_entity):
	# Register into Stats comp
	p_entity.comph().call_comp("Stats", "register_status_effect", [self])

func deactivate(p_entity):
	# Deregister from Stats comp
	p_entity.comph().call_comp("Stats", "deregister_status_effect", [self])

func get_stat():
	return _e_stat

func get_modified_value(p_value):
	return _e_mult * p_value + _e_add
