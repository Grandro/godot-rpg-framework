extends Node
class_name BattleSV

signal battle_ended(p_location, p_res)

enum MAP_RES {PARTY_MEMBER, ENEMY, NEUTRAL}

@onready var _a_Result = get_node("Result")

var _a_return_map = null # Used to keep map in cache
var _a_return_location = "" # Location to return to after battle
var _a_res = "" # Win/Loss

func _ready():
	_a_Result.closed.connect(_on_Result_closed)

func battle(p_enc_key, p_map_res):
	var scene_manager_si = Global.get_singleton(self, "Scene_Manager")
	_a_return_map = scene_manager_si.get_curr_scene()
	_a_return_location = scene_manager_si.get_location()
	
	var data = Databases.get_data_entry("SV_Encounters", p_enc_key)
	var path = data.get_path_()
	scene_manager_si.change_scene_path(path, _CB_Scene_Manager_Encounter_Set.bind(p_map_res))

func _tp_to_return_location():
	var scene_manager_si = Global.get_singleton(self, "Scene_Manager")
	var cb_method = _CB_Scene_Manager_Return_Scene_Set.bind(_a_return_location, _a_res)
	scene_manager_si.change_scene_tele(_a_return_location, cb_method)

func _CB_Scene_Manager_Encounter_Set(p_instance, p_map_res):
	p_instance.battle_ended.connect(_on_Encounter_battle_ended)
	p_instance.set_map_res(p_map_res)
	p_instance.battle()

func _CB_Scene_Manager_Return_Scene_Set(_p_instance, p_location, p_res):
	battle_ended.emit(p_location, p_res)

func _on_Result_closed():
	_tp_to_return_location()

func _on_Encounter_battle_ended(_p_location, p_res, p_EXP, p_loot):
	# Open Result
	_a_res = p_res
	
	match p_res:
		"Flee":
			_tp_to_return_location()
		_:
			_a_Result.open(p_EXP, p_loot)
