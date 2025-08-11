extends Node3D

class_name SVEncounterBase

signal battle_ended(p_location, p_res)

@export var _e_BGM : AudioPlayback = null
@export var _e_BGS : Array[AudioPlayback] = []
@export var _e_pm_comps : Array[PackedScene] = []

const _a_PARTY_MEMBER_SCENE_PATH = "res://Global_Scenes/Battle_System/Battle_SV/Party_Members/%s/%s.tscn"
const _a_ENEMY_SCENE_PATH = "res://Global_Scenes/Battle_System/Battle_SV/Enemies/%s/%s.tscn"
const _a_COMMAND_LOC_ID = "SV_ACTIONS_%s"

var _a_Popup_Scene = preload("res://Global_Scenes/Battle_System/Popup.tscn")

@onready var _a_Free_Camera = get_node("Objects/$Free_Camera")
@onready var _a_Free_Audio = get_node("Objects/$Free_Audio")
@onready var _a_Party_Members_Place_Pos = get_node("Objects/Party_Members/Place_Pos")
@onready var _a_Party_Members_Instances = get_node("Objects/Party_Members/Instances")
@onready var _a_Enemies_Place_Pos = get_node("Objects/Enemies/Place_Pos")
@onready var _a_Enemies_Instances = get_node("Objects/Enemies/Instances")
@onready var _a_Popups = get_node("Objects/Popups")
@onready var _a_Flee_Pos = get_node("Flee_Pos")
@onready var _a_Command_Circle = get_node("Command_Circle")
@onready var _a_Rating = get_node("Rating")
@onready var _a_Indicators = get_node("Indicators")
@onready var _a_Enemy_Select = get_node("Enemy_Select")
@onready var _a_Specials_Menu = get_node("Canvas/Specials_Menu")
@onready var _a_Speedlines = get_node("Canvas/Speedlines")
@onready var _a_Stats_Display = get_node("Canvas/Stats_Display")

var _a_map_res = -1 # Result of how the battle started on map
var _a_troop = [] # Enemy keys
var _a_special = false # Special battles have a predefined troop
var _a_order = [] # Attack order of battlers
var _a_order_idx = -1 # Current idx of _a_order
var _a_instance = null # Currently active battler
var _a_battle_ended = false # Has battle ended?

var _a_characters = {} # Match key to instance
var _a_party_members = {} # Match party member key to instance
var _a_enemies = {} # Match enemy key to instance
var _a_characters_alive = {} # Match key to instance
var _a_party_members_alive = {} # Match key to instance
var _a_enemies_alive = {} # Match key to instance

func _ready():
	_a_Command_Circle.changed.connect(_on_Command_Circle_changed)
	_a_Command_Circle.selected.connect(_on_Command_Circle_selected)
	_a_Enemy_Select.changed.connect(_on_Enemy_Select_changed)
	_a_Enemy_Select.selected.connect(_on_Enemy_Select_selected)
	_a_Enemy_Select.canceled.connect(_on_Enemy_Select_canceled)
	_a_Specials_Menu.selected.connect(_on_Specials_Menu_selected)
	_a_Specials_Menu.canceled.connect(_on_Specials_Menu_canceled)
	
	var global_si = Global.get_singleton(self, "Global")
	var camera_comp = _a_Free_Camera.comph().get_comp("Camera")
	global_si.init_camera_limit()
	global_si.set_curr_camera(camera_comp)
	
	_play_BGM()
	_play_BGS()

func instantiate_popup(p_type, p_to, p_text):
	var instance = _a_Popup_Scene.instantiate()
	instance.set_text.call_deferred(p_text)
	match p_type:
		"Damage": instance.set_modulate.call_deferred(Battle_System.a_DAMAGE_COLOR)
		"Heal": instance.set_modulate.call_deferred(Battle_System.a_HEAL_COLOR)
	
	var pos = p_to.get_global_position()
	var offset = p_to.get_popup_offset()
	_a_Popups.add_child(instance)
	instance.set_global_position(pos + offset)

func deal_dmg_rating(p_from, p_to):
	var rating = p_from.get_timing_rating()
	var dmg_fac = _get_pm_dmg_fac(rating)
	var from_ATK = p_from.comph().call_comp("Stats", "get_curr_stat", ["ATK"])
	var to_DEF = p_to.comph().call_comp("Stats", "get_curr_stat", ["DEF"])
	var ATK = int(round(from_ATK * dmg_fac))
	var dmg = ATK - to_DEF
	_deal_dmg(p_from, p_to, dmg)
	display_rating(p_to, rating)

func deal_dmg(p_from, p_to):
	var from_atk = p_from.comph().call_comp("Stats", "get_curr_stat", ["ATK"])
	var to_def = p_to.comph().call_comp("Stats", "get_curr_stat", ["DEF"])
	var dmg = from_atk - to_def
	_deal_dmg(p_from, p_to, dmg)

func _deal_dmg(p_from, p_to, p_dmg):
	instantiate_popup("Damage", p_to, str(p_dmg))
	
	var from_pos = p_from.get_global_position()
	var to_pos = p_to.get_global_position()
	var dir_vec = from_pos.direction_to(to_pos)
	p_to.process_dmg(p_dmg)
	_knockback(p_to, p_dmg, dir_vec)

func display_rating(p_instance, p_rating):
	var pos = p_instance.get_global_position()
	var offset = p_instance.get_rating_offset()
	_a_Rating.display(pos + offset, p_rating)

func battle_end(p_res):
	_a_battle_ended = true
	
	# Change party member data based on stats after battle
	var global_si = Global.get_singleton(self, "Global")
	for key in _a_party_members:
		var instance = _a_party_members[key]
		var HP = instance.comph().call_comp("Stats", "get_curr_stat", ["HP"])
		var SP = instance.comph().call_comp("Stats", "get_curr_stat", ["SP"])
		global_si.set_party_member_stat(key, "HP", max(HP, 1))
		global_si.set_party_member_stat(key, "SP", SP)
	
	var total_EXP = 0
	var total_loot = {} # Match item_key to amount
	for instance in _a_enemies.values():
		var EXP = instance.get_EXP()
		var loot = instance.get_loot()
		var rolled_loot = global_si.roll_loot(loot)
		
		total_EXP += EXP
		for item_key in rolled_loot:
			var amount = rolled_loot[item_key]
			if total_loot.has(item_key):
				total_loot[item_key] += amount
			else:
				total_loot[item_key] = amount
	
	var scene_manager_si = Global.get_singleton(self, "Scene_Manager")
	var location = scene_manager_si.get_location()
	battle_ended.emit(location, p_res, total_EXP, total_loot)
	
	_a_Speedlines.hide()
	_a_Stats_Display.hide()

func battle():
	if !_a_special:
		_instantiate_party_members()
		_instantiate_enemies()
	_init_party_members()
	_init_enemies()
	
	_a_Stats_Display.open(_a_party_members)
	
	_update_order()
	_handle_map_res()

func _play_BGM():
	if _e_BGM == null:
		return
	
	var audio_manager_si = Global.get_singleton(self, "Audio_Manager")
	var stream = _e_BGM.get_stream()
	var volume = _e_BGM.get_volume()
	var pitch = _e_BGM.get_pitch()
	var from = _e_BGM.get_from()
	var player = audio_manager_si.replace_bgm(stream, volume, pitch, from)
	audio_manager_si.flatten_bgm(player)

func _play_BGS():
	var audio_manager_si = Global.get_singleton(self, "Audio_Manager")
	var players = []
	for BGS in _e_BGS:
		var stream = BGS.get_stream()
		var volume = BGS.get_volume()
		var pitch = BGS.get_pitch()
		var from = BGS.get_from()
		var player = audio_manager_si.replace_bgs(stream, volume, pitch, from)
		players.push_back(player)
	audio_manager_si.flatten_bgs(players)

func _instantiate_party_members():
	var global_si = Global.get_singleton(self, "Global")
	var party_members = global_si.get_party_members_active()
	var keys = party_members.keys()
	var amount = keys.size()
	var place_pos = _a_Party_Members_Place_Pos.get_place_pos(amount)
	for i in amount:
		var key = keys[i]
		var path = _a_PARTY_MEMBER_SCENE_PATH % [key, key]
		var scene = load(path)
		var instance = scene.instantiate()
		var pos = place_pos[i]
		instance.set_position(pos)
		_a_Party_Members_Instances.add_child(instance)
		
		for comp_scene in _e_pm_comps:
			var comp_instance = comp_scene.instantiate()
			instance.comph().add_comp(comp_instance)

func _instantiate_enemies():
	var amount = _a_troop.size()
	var place_pos = _a_Enemies_Place_Pos.get_place_pos(amount)
	for i in amount:
		var enemy_key = _a_troop[i]
		var path = _a_ENEMY_SCENE_PATH % [enemy_key, enemy_key]
		var scene = load(path)
		var instance = scene.instantiate()
		var pos = place_pos[i]
		instance.set_position(pos)
		_a_Enemies_Instances.add_child(instance)

func _init_party_members():
	var global_si = Global.get_singleton(self, "Global")
	var party_members = global_si.get_party_members()
	for instance in _a_Party_Members_Instances.get_children():
		var key = instance.comph().call_comp("Party_Member", "get_pm_key")
		var args = party_members[key]
		var stats = args["Stats"]
		var actions = args["Actions"]
		instance.action_started.connect(_on_Character_action_started.bind(instance))
		instance.action_finished.connect(_on_Character_action_finished)
		instance.action_canceled.connect(_on_Character_action_canceled)
		instance.action_pre_event.connect(_on_Character_action_pre_event.bind(instance))
		instance.action_post_event.connect(_on_Character_action_post_event.bind(instance))
		instance.action_finished.connect(_on_Party_Member_action_finished.bind(instance))
		instance.hit.connect(_on_Party_Member_hit.bind(instance))
		instance.died.connect(_on_Party_Member_died.bind(key))
		instance.comph().call_comp("Stats", "set_max_stat", ["HP", stats["HP"]])
		instance.comph().call_comp("Stats", "set_max_stat", ["SP", stats["SP"]])
		instance.comph().call_comp("Stats", "set_curr_stat", ["HP", stats["HP"]])
		instance.comph().call_comp("Stats", "set_curr_stat", ["SP", stats["SP"]])
		instance.comph().call_comp("Stats", "set_curr_stat", ["ATK", stats["ATK"]])
		instance.comph().call_comp("Stats", "set_curr_stat", ["MAG", stats["MAG"]])
		instance.comph().call_comp("Stats", "set_curr_stat", ["DEF", stats["DEF"]])
		instance.comph().call_comp("Stats", "set_curr_stat", ["SPEED", stats["SPEED"]])
		instance.comph().call_comp("Stats", "set_curr_stat", ["LUCK", stats["LUCK"]])
		
		instance.set_encounter(self)
		instance.set_actions(actions)
		
		_a_characters[key] = instance
		_a_party_members[key] = instance
		_a_characters_alive[key] = instance
		_a_party_members_alive[key] = instance

func _init_enemies():
	var enemies_data = Databases.get_data("Enemies")
	for i in _a_Enemies_Instances.get_child_count():
		var instance = _a_Enemies_Instances.get_child(i)
		var enemy_key = instance.get_key()
		var key = "%s_%s" % [enemy_key, i]
		var args = enemies_data[enemy_key]
		var stats = args.get_stats()
		var actions = args.get_actions()
		instance.action_finished.connect(_on_Character_action_finished)
		instance.action_canceled.connect(_on_Character_action_canceled)
		instance.action_pre_event.connect(_on_Character_action_pre_event.bind(instance))
		instance.action_post_event.connect(_on_Character_action_post_event.bind(instance))
		instance.action_reaction_started.connect(_on_Enemy_action_reaction_started)
		instance.action_reaction_finished.connect(_on_Enemy_action_reaction_finished)
		instance.hit.connect(_on_Enemy_hit.bind(instance))
		instance.died.connect(_on_Enemy_died.bind(key))
		instance.set_EXP(stats.get_EXP())
		instance.set_loot(stats.get_loot())
		instance.comph().call_comp("Stats", "set_max_stat", ["HP", stats.get_HP()])
		instance.comph().call_comp("Stats", "set_max_stat", ["SP", stats.get_SP()])
		instance.comph().call_comp("Stats", "set_curr_stat", ["HP", stats.get_HP()])
		instance.comph().call_comp("Stats", "set_curr_stat", ["SP", stats.get_SP()])
		instance.comph().call_comp("Stats", "set_curr_stat", ["ATK", stats.get_ATK()])
		instance.comph().call_comp("Stats", "set_curr_stat", ["MAG", stats.get_MAG()])
		instance.comph().call_comp("Stats", "set_curr_stat", ["DEF", stats.get_DEF()])
		instance.comph().call_comp("Stats", "set_curr_stat", ["SPEED", stats.get_SPEED()])
		instance.comph().call_comp("Stats", "set_curr_stat", ["LUCK", stats.get_LUCK()])
		
		instance.set_encounter(self)
		instance.comph().call_comp("Actions", "update_data", [actions])
		
		_a_characters[key] = instance
		_a_enemies[key] = instance
		_a_characters_alive[key] = instance
		_a_enemies_alive[key] = instance

func _handle_map_res():
	match _a_map_res:
		BattleSV.MAP_RES.PARTY_MEMBER:
			_a_instance = _a_Party_Members_Instances.get_child(0)
			_proceed_battle()
		BattleSV.MAP_RES.ENEMY:
			_a_instance = _a_Enemies_Instances.get_child(0)
			_proceed_battle()
		BattleSV.MAP_RES.NEUTRAL:
			_update_turn()
			_proceed_battle()

func _proceed_battle():
	var type = _a_instance.get_type()
	match type:
		"Party_Member":
			_a_Command_Circle.open(_a_instance)
			var pos = _a_Command_Circle.get_global_position()
			_a_Indicators.open_command_circle(pos)
		"Enemy":
			_a_instance.process_action_start()

func _update_turn():
	if _a_order_idx == _a_order.size() - 1:
		_update_order()
	_a_order_idx = (_a_order_idx + 1) % _a_order.size()
	
	var key = _a_order[_a_order_idx]
	_a_instance = _a_characters[key]

func _update_order():
	_a_order.clear()
	var order_args = []
	for key in _a_characters_alive:
		var instance = _a_characters_alive[key]
		var SPEED = instance.comph().call_comp("Stats", "get_curr_stat", ["SPEED"])
		instance.set_turn_completed(false)
		order_args.push_back([SPEED, key])
	
	order_args.sort_custom(Global.sort_high)
	
	for args in order_args:
		var key = args[1]
		_a_order.push_back(key)

func _erase_from_order(p_key):
	_a_order.erase(p_key)
	var instance = _a_characters[p_key]
	var turn_completed = instance.get_turn_completed()
	if turn_completed:
		_a_order_idx -= 1

func _game_over():
	var scene_manager_si = Global.get_singleton(self, "Scene_Manager")
	scene_manager_si.change_scene_dest(["Game_Over", "Start"])

func _knockback(p_instance, p_dmg, p_dir_vec):
	var velocity = p_dir_vec * p_dmg * 1.5
	p_instance.comph().call_subcomp("Movement", "Knockbacks", "knockback", [velocity])

func set_map_res(p_map_res):
	_a_map_res = p_map_res

func set_troop(p_troop):
	_a_troop = p_troop

func set_special(p_special):
	_a_special = p_special

func get_character(p_key):
	return _a_characters[p_key]

func get_party_members():
	return _a_party_members

func get_enemies():
	return _a_enemies

func get_free_camera():
	return _a_Free_Camera

func get_free_audio():
	return _a_Free_Audio

func get_flee_pos():
	return _a_Flee_Pos.get_global_position()

func _get_pm_dmg_fac(p_rating):
	match p_rating:
		"Nothing": return 0.5
		"OK": return 0.75
		"Good": return 1.0
		"Great": return 1.25
		"Excellent": return 1.5

func _on_Command_Circle_changed(p_command):
	var text = _a_COMMAND_LOC_ID % p_command.to_upper()
	_a_Indicators.set_command_circle_command_text(text)

func _on_Command_Circle_selected(p_command):
	_a_instance.set_command(p_command)
	_a_Command_Circle.close()
	_a_Indicators.close_command_circle()
	
	var command_args = _a_instance.get_curr_command_arg()
	var target_type = command_args.get_target_type()
	match target_type:
		"None":
			match p_command:
				"Special":
					_a_Specials_Menu.open(_a_instance)
					_a_Indicators.open_specials_menu()
				_:
					_a_instance.process_action_start()
		
		"Ally":
			pass
		
		"Enemy":
			_a_Enemy_Select.open(_a_enemies_alive)
			_a_Indicators.open_enemy_select()

func _on_Enemy_Select_changed(p_key, p_init):
	var instance = _a_enemies[p_key]
	_a_Indicators.update_enemy_select(instance, p_init)

func _on_Enemy_Select_canceled():
	_a_Indicators.close_enemy_select()
	
	var command = _a_instance.get_command()
	match command:
		"Special":
			_a_Specials_Menu.open(_a_instance)
			_a_Indicators.open_specials_menu()
		_:
			_a_Command_Circle.open(_a_instance)
			var pos = _a_Command_Circle.get_global_position()
			_a_Indicators.open_command_circle(pos)

func _on_Enemy_Select_selected(p_key):
	_a_Indicators.close_enemy_select()
	
	var target = _a_enemies[p_key]
	_a_instance.set_target(target)
	_a_instance.process_action_start()

func _on_Specials_Menu_selected(p_args):
	var special = p_args.get_key()
	var target_type = p_args.get_target_type()
	_a_instance.set_special(special)
	_a_Indicators.close_specials_menu()
	
	match target_type:
		"None":
			_a_instance.process_action_start()
		
		"Ally":
			pass
		
		"Enemy":
			_a_Enemy_Select.open(_a_enemies_alive)
			_a_Indicators.open_enemy_select()

func _on_Specials_Menu_canceled():
	_a_Indicators.close_specials_menu()
	
	_a_Command_Circle.open(_a_instance)
	var pos = _a_Command_Circle.get_global_position()
	_a_Indicators.open_command_circle(pos)

func _on_Character_action_started(p_instance):
	p_instance.comph().call_comp("Status", "handle_trigger_effects", ["Action_Start"])

func _on_Character_action_finished():
	if _a_battle_ended:
		return
	
	_update_turn()
	_proceed_battle()

func _on_Character_action_canceled():
	_proceed_battle()

func _on_Character_action_pre_event(p_instance):
	p_instance.comph().call_comp("Status", "handle_trigger_effects", ["Action_Pre_Event"])

func _on_Character_action_post_event(p_instance):
	p_instance.comph().call_comp("Status", "handle_trigger_effects", ["Action_Post_Event"])

func _on_Party_Member_action_finished(p_instance):
	var command = p_instance.get_command()
	match command:
		"Flee":
			battle_end("Flee")

func _on_Party_Member_hit(p_to, p_from):
	deal_dmg_rating(p_from, p_to)

func _on_Party_Member_died(p_key):
	_a_characters_alive.erase(p_key)
	_a_party_members_alive.erase(p_key)
	_erase_from_order(p_key)
	
	if _a_party_members_alive.is_empty():
		_game_over()

func _on_Enemy_action_reaction_started(p_target):
	var reactions = p_target.get_reactions()
	_a_Indicators.open_reaction(reactions)
	p_target.reaction_start()

func _on_Enemy_action_reaction_finished(p_target):
	_a_Indicators.close_reaction()
	p_target.reaction_end()

func _on_Enemy_hit(p_to, p_from):
	deal_dmg(p_from, p_to)

func _on_Enemy_died(p_key):
	_a_characters_alive.erase(p_key)
	_a_enemies_alive.erase(p_key)
	_erase_from_order(p_key)
	
	if _a_enemies_alive.is_empty():
		battle_end("Win")
