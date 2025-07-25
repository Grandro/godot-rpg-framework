extends Node3D

class_name SVEncounterBase

signal battle_ended(p_location, p_res)

@export var _e_BGM : AudioPlayback = null
@export var _e_BGS : Array[AudioPlayback] = []
@export var _e_special: bool = false

const _a_PARTY_MEMBER_SCENE_PATH = "res://Global_Scenes/Battle_System/Battle_SV/Party_Members/%s/%s.tscn"
const _a_COMMAND_LOC_ID = "SV_ACTIONS_%s"

var _a_Popup_Scene = preload("res://Global_Scenes/Battle_System/Popup.tscn")

@onready var _a_Free_Camera = get_node("Objects/$Free_Camera")
@onready var _a_Free_Audio = get_node("Objects/$Free_Audio")
@onready var _a_Party_Members_Place_Pos = get_node("Objects/Party_Members/Place_Pos")
@onready var _a_Party_Members_Instances = get_node("Objects/Party_Members/Instances")
@onready var _a_Enemies = get_node("Objects/Enemies")
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
var _a_order = [] # Attack order of battlers
var _a_order_idx = -1 # Current index of _a_order
var _a_instance = null # Currently active battler
var _a_battle_ended = false # Has battle ended?

var _a_characters = {} # Match key to instance
var _a_party_members = {} # Match party member key to instance
var _a_enemies = {} # Match enemy key to instance

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

func instantiate_popup(p_to, p_type, p_text):
	var instance = _a_Popup_Scene.instantiate()
	instance.set_text.call_deferred(p_text)
	match p_type:
		"Damage": instance.set_modulate.call_deferred(Battle_System.a_DAMAGE_COLOR)
		"Heal": instance.set_modulate.call_deferred(Battle_System.a_HEAL_COLOR)
	
	var pos = p_to.get_global_position()
	var offset = p_to.get_popup_offset()
	_a_Popups.add_child(instance)
	instance.set_global_position(pos + offset)

func deal_damage_enemy(p_from, p_to, p_rating):
	var damage_fac = _get_pm_damage_fac(p_rating)
	var from_ATK = p_from.comph().call_comp("Stats", "get_curr_stat", ["ATK"])
	var to_DEF = p_to.comph().call_comp("Stats", "get_curr_stat", ["DEF"])
	var atk = int(round(from_ATK * damage_fac))
	var dmg = atk - to_DEF
	instantiate_popup(p_to, "Damage", str(dmg))
	
	display_rating(p_to, p_rating)
	
	p_to.comph().call_comp("Stats", "decrease_curr_stat", ["HP", dmg])
	
	# Knock enemy back
	var velocity = Vector3.RIGHT
	velocity *= damage_fac * 7.5
	p_to.comph().call_subcomp("Movement", "Knockbacks", "knockback", [velocity])

func deal_damage_pm(p_from, p_to):
	var from_atk = p_from.comph().call_comp("Stats", "get_curr_stat", ["ATK"])
	var to_def = p_to.comph().call_comp("Stats", "get_curr_stat", ["DEF"])
	var dmg = from_atk - to_def
	instantiate_popup(p_to, "Damage", str(dmg))
	
	p_to.process_damage(dmg)

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
	if !_e_special:
		_instantiate_party_members()
	_init_party_members()
	_init_enemies()
	
	var pm_instances = _a_Party_Members_Instances.get_children()
	_a_Stats_Display.open(pm_instances)
	
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

func _init_party_members():
	var global_si = Global.get_singleton(self, "Global")
	var party_members = global_si.get_party_members()
	var instances = _a_Party_Members_Instances.get_children()
	for instance in instances:
		var key = instance.comph().call_comp("Reference", "get_key")
		var args = party_members[key]
		var stats = args["Stats"]
		var actions = args["Actions"]
		
		instance.action_started.connect(_on_Character_action_started.bind(instance))
		instance.action_pre_event.connect(_on_Character_action_pre_event.bind(instance))
		instance.action_post_event.connect(_on_Character_action_post_event.bind(instance))
		instance.turn_completed.connect(_on_Character_turn_completed)
		instance.turn_canceled.connect(_on_Character_turn_canceled)
		instance.died.connect(_on_Party_Member_died.bind(instance))
		instance.fled.connect(_on_Party_Member_fled)
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
		
		_a_party_members[key] = instance
		_a_characters[key] = instance

func _init_enemies():
	var enemies_data = Databases.get_data("Enemies")
	var instances = _a_Enemies.get_children()
	for instance in instances:
		var key = instance.comph().call_comp("Reference", "get_key")
		var args = enemies_data[key]
		var stats = args.get_stats()
		var actions = args.get_actions()
		
		instance.action_pre_event.connect(_on_Character_action_pre_event.bind(instance))
		instance.action_post_event.connect(_on_Character_action_post_event.bind(instance))
		instance.turn_completed.connect(_on_Character_turn_completed)
		instance.turn_canceled.connect(_on_Character_turn_canceled)
		instance.died.connect(_on_Enemy_died.bind(instance))
		instance.hit.connect(_on_Enemy_hit)
		instance.attack_pm_started.connect(_on_Enemy_attack_pm_started)
		instance.attack_pm_finished.connect(_on_Enemy_attack_pm_finished)
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
		instance.update_actions_data(actions)
		
		_a_enemies[key] = instance
		_a_characters[key] = instance

func _handle_map_res():
	match _a_map_res:
		BattleSV.MAP_RES.PARTY_MEMBER:
			_a_instance = _a_Party_Members_Instances.get_child(0)
			_proceed_battle()
		BattleSV.MAP_RES.ENEMY:
			_a_instance = _a_Enemies.get_child(0)
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
	for instance in _a_characters.values():
		instance.set_turn_completed(false)
		
		var HP = instance.comph().call_comp("Stats", "get_curr_stat", ["HP"])
		if HP == 0:
			continue
		
		var SPEED = instance.comph().call_comp("Stats", "get_curr_stat", ["SPEED"])
		var key = instance.comph().call_comp("Reference", "get_key")
		order_args.push_back([SPEED, key])
	order_args.sort_custom(Global.sort_high)
	
	for args in order_args:
		var key = args[1]
		_a_order.push_back(key)

func _erase_from_order(p_instance):
	var key = p_instance.comph().call_comp("Reference", "get_key")
	_a_order.erase(key)
	var turn_completed = p_instance.get_turn_completed()
	if turn_completed:
		_a_order_idx -= 1

func _game_over():
	var scene_manager_si = Global.get_singleton(self, "Scene_Manager")
	scene_manager_si.change_scene_dest(["Game_Over", "Start"])

func set_map_res(p_map_res):
	_a_map_res = p_map_res

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

func _get_pm_damage_fac(p_rating):
	match p_rating:
		"Nothing": return 0.5
		"OK": return 0.75
		"Good": return 1.0
		"Great": return 1.25
		"Excellent": return 1.5

func get_save_data():
	return {}

func load_data(_p_map_data):
	pass

func load_data_init():
	pass

func _on_Command_Circle_changed(p_command):
	var text = _a_COMMAND_LOC_ID % p_command.to_upper()
	_a_Indicators.set_command_circle_command_text(text)

func _on_Command_Circle_selected(p_command):
	_a_instance.set_command(p_command)
	_a_Command_Circle.close()
	_a_Indicators.close_command_circle()
	
	var command_args = _a_instance.get_curr_command_args()
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
			_a_Enemy_Select.open(_a_enemies)
			_a_Indicators.open_enemy_select()

func _on_Enemy_Select_changed(p_instance):
	_a_Indicators.update_enemy_select(p_instance)

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

func _on_Enemy_Select_selected(p_instance):
	_a_Indicators.close_enemy_select()
	
	_a_instance.set_target(p_instance)
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
			_a_Enemy_Select.open(_a_enemies)
			_a_Indicators.open_enemy_select()

func _on_Specials_Menu_canceled():
	_a_Indicators.close_specials_menu()
	
	_a_Command_Circle.open(_a_instance)
	var pos = _a_Command_Circle.get_global_position()
	_a_Indicators.open_command_circle(pos)

func _on_Character_action_started(p_instance):
	p_instance.comph().call_comp("Status", "handle_trigger_effects", ["Action_Start"])

func _on_Character_action_pre_event(p_instance):
	p_instance.comph().call_comp("Status", "handle_trigger_effects", ["Action_Pre_Event"])

func _on_Character_action_post_event(p_instance):
	p_instance.comph().call_comp("Status", "handle_trigger_effects", ["Action_Post_Event"])

func _on_Character_turn_completed():
	if _a_battle_ended:
		return
	
	_update_turn()
	_proceed_battle()

func _on_Character_turn_canceled():
	_proceed_battle()

func _on_Party_Member_died(p_instance):
	_erase_from_order(p_instance)
	
	# Check if all party members are dead for game over
	var all_dead = true
	for instance in _a_party_members.values():
		var HP = instance.comph().call_comp("Stats", "get_curr_stat", ["HP"])
		if HP > 0:
			all_dead = false
			break
	
	if all_dead:
		_game_over()

func _on_Party_Member_fled():
	battle_end("Flee")

func _on_Enemy_died(p_instance):
	_erase_from_order(p_instance)
	
	# Check if all enemies are dead for battle win
	var all_dead = true
	for instance in _a_enemies.values():
		var HP = instance.comph().call_comp("Stats", "get_curr_stat", ["HP"])
		if HP > 0:
			all_dead = false
			break
	
	if all_dead:
		battle_end("Win")

func _on_Enemy_hit(p_from, p_to):
	deal_damage_pm(p_from, p_to)

func _on_Enemy_attack_pm_started(p_target):
	var reactions = p_target.get_reactions()
	_a_Indicators.open_enemy_attack(reactions)
	p_target.enemy_attack_start()

func _on_Enemy_attack_pm_finished(p_target):
	_a_Indicators.close_enemy_attack()
	p_target.enemy_attack_end()
