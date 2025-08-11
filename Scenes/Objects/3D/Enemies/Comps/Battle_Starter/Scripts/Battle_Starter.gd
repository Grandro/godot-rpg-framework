extends Node3D

signal battle_starting()

@export var _e_enc_key = ""
@export var _e_troops : Dictionary[Array, int] = {}

var _a_entity: Node3D = null

var _a_troops_RNG = DicRNG.new()

func _ready():
	for child in get_children():
		child.area_entered.connect(_on_Area_area_entered.bind(child))
		child.body_entered.connect(_on_Area_body_entered.bind(child))
	
	_a_troops_RNG.set_dic(_e_troops)

func init(p_entity):
	_a_entity = p_entity
	p_entity.visibility_changed.connect(_on_entity_visibility_changed)

func start_battle(p_map_res):
	var troop = _a_troops_RNG.roll_key()
	var battle_system_si = Global.get_singleton(self, "Battle_System")
	var battle_sv = battle_system_si.get_battle_sv()
	battle_starting.emit()
	battle_sv.battle(_e_enc_key, p_map_res, troop)

func get_save_data():
	return {}

func load_data(_p_data):
	pass

func load_data_init():
	pass

func _on_Area_area_entered(_p_area, p_instance):
	var res = p_instance.get_res()
	start_battle(res)

func _on_Area_body_entered(_p_body, p_instance):
	var res = p_instance.get_res()
	start_battle(res)

func _on_entity_visibility_changed():
	var is_visible_ = _a_entity.is_visible()
	for child in get_children():
		child.set_monitoring.call_deferred(is_visible_)
