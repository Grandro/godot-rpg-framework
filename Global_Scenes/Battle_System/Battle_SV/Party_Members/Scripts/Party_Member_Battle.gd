extends "res://Global_Scenes/Battle_System/Battle_SV/Scripts/Character_Battle.gd"

signal fled()

@export var _e_command_circle_offset: Vector3 = Vector3.ZERO
@export var _e_reactions: Dictionary = {} # Match reaction key to button

@onready var _a_Audio = get_node("Audio")
@onready var _a_Movement = get_node("Movement")
@onready var _a_Movement_Nav_Agent = get_node("Movement/Nav_Agent")
@onready var _a_Movement_Jump = get_node("Movement/Jump")
@onready var _a_States = get_node("States")
@onready var _a_Stats = get_node("Stats")
@onready var _a_Anims = get_node("Anims")
@onready var _a_Shield_Bar = get_node("Shield_Bar")

var _a_actions = {}
var _a_action_on_cd = false # Is action on CD?
var _a_action_time = 0.0 # Action timestamp
var _a_action_dif = 0.0 # Action timing difference

func _ready():
	super()
	_a_Anims.animation_finished.connect(_on_Anims_anim_finished)
	_a_Movement_Nav_Agent.path_finished.connect(_on_Movement_Nav_Agent_path_finished)
	_a_Movement_Jump.jumped.connect(_on_Movement_Jump_jumped)
	
	set_process_unhandled_input(false)

func _unhandled_input(p_event):
	if _a_action_on_cd:
		return
	
	if _a_on_turn:
		_process_action_event(p_event)
	else:
		_process_reaction_event(p_event)

func process_damage(p_dmg):
	match _a_command:
		"Defense_DEF":
			var time = Time.get_ticks_msec() / 1000.0
			_a_action_dif = time - _a_action_time
			var rating = _get_timing_rating()
			_a_encounter.display_rating(self, rating)
			
			var defense_fac = _get_defense_fac(rating)
			var dmg = int(p_dmg / defense_fac)
			_a_Stats.decrease_curr_stat("HP", dmg)
			
			var shield_gain = _get_shield_gain(rating)
			_a_Shield_Bar.open(shield_gain)
		_:
			_a_Stats.decrease_curr_stat("HP", p_dmg)

func enemy_attack_start():
	_a_action_on_cd = false
	_a_action_dif = 0.0
	set_process_unhandled_input(true)

func enemy_attack_end():
	set_process_unhandled_input(false)
	_a_States.set_state_tmp("Idle")
	_a_Anims.update_anim()

func _process_action_flee():
	var party_members = _a_encounter.get_party_members()
	var pm_avg_SPEED = 0
	for instance in party_members.values():
		var SPEED = instance.comph().call_comp("Stats", "get_curr_stat", ["SPEED"])
		pm_avg_SPEED += SPEED
	pm_avg_SPEED /= party_members.size()
	
	var enemies = _a_encounter.get_enemies()
	var enemies_avg_SPEED = 0
	for instance in enemies.values():
		var SPEED = instance.comph().call_comp("Stats", "get_curr_stat", ["SPEED"])
		enemies_avg_SPEED += SPEED
	enemies_avg_SPEED /= enemies.size()
	
	if pm_avg_SPEED >= enemies_avg_SPEED:
		_process_action_flee_success(party_members)
	else:
		_process_action_flee_fail()

func _process_action_flee_success(p_party_members):
	var flee_pos = _a_encounter.get_flee_pos()
	for instance in p_party_members.values():
		var pos = instance.get_global_position()
		flee_pos = Vector3(flee_pos.x, pos.y, pos.z)
		
		_a_Audio.play("Flee")
		_a_States.set_state("Walk")
		_a_Movement.set_state("Move_To_Flee_Pos")
		_a_Movement.move_to_pos(flee_pos)
		_a_Anims.update_anim()

func _process_action_flee_fail():
	pass

func _process_action_event(p_event):
	match _a_command:
		"Attack_ATK": _process_action_event_attack_ATK(p_event)

func _process_reaction_event(p_event):
	match _a_command:
		"Defense_DEF": _process_reaction_event_defend_DEF(p_event)
		_: _process_reaction_event_counter(p_event)

func _process_action_event_attack_ATK(p_event):
	if p_event.is_action_pressed("OK"):
		_a_action_on_cd = true
		
		_a_Audio.play("Perform")
		var curr_time = _a_Anims.get_current_animation_position()
		var max_time = _a_Anims.get_current_animation_length()
		_a_action_dif = max_time - curr_time
		
		_a_States.set_state_tmp("Attack_ATK_Hit")
		_a_Anims.update_anim()

func _process_reaction_event_defend_DEF(p_event):
	if p_event.is_action_pressed("OK"):
		_a_action_on_cd = true
		_a_Audio.play("Perform")
		_a_action_time = Time.get_ticks_msec() / 1000.0
		
		_a_States.set_state_tmp("Defend_DEF")
		_a_Anims.update_anim()

func _process_reaction_event_counter(p_event):
	if p_event.is_action_pressed("Jump"):
		_a_action_on_cd = true
		_a_Movement_Jump.jump()
	
	elif p_event.is_action_pressed("Duck"):
		_a_action_on_cd = true
		_a_States.set_state_tmp("Duck")
		_a_Anims.update_anim()

func get_command_circle_offset():
	return _e_command_circle_offset

func get_reactions():
	if _e_reactions.has(_a_command):
		return _e_reactions[_a_command]
	else:
		return _e_reactions["$Default"]

func set_actions(p_actions):
	_a_actions = p_actions
	
	update_actions_data(p_actions)

func get_active_actions(p_type):
	var active = []
	for key in _a_actions[p_type]:
		var state = _a_actions[p_type][key]
		if state == "Enabled":
			active.push_back(key)
	
	return active

func _get_timing_rating():
	# NOTHING: Not pressed
	# EXCELLENT: 0.0 - 0.3
	# GREAT: 0.3 - 0.7
	# GOOD: 0.7 - 1.1
	# OK: 1.1 - 1.3
	
	var rating = "Nothing"
	if !_a_action_on_cd:
		return rating
	
	if _a_action_dif <= 0.3:
		rating = "Excellent"
	elif _a_action_dif <= 0.7:
		rating = "Great"
	elif _a_action_dif <= 1.1:
		rating = "Good"
	elif _a_action_dif <= 1.3:
		rating = "OK"
	
	return rating

func _get_defense_fac(p_rating):
	match p_rating:
		"Nothing": return 1.0
		"OK": return 1.25
		"Good": return 1.5
		"Great": return 1.75
		"Excellent": return 2.0

func _get_shield_gain(p_rating):
	match p_rating:
		"Nothing": return 0
		"OK": return 1
		"Good": return 2
		"Great": return 3
		"Excellent": return 4

func _on_Anims_anim_finished(p_name):
	if "Duck" in p_name:
		_a_action_on_cd = false
		_a_States.set_state_tmp("Idle")
		_a_Anims.update_anim()

func _on_Movement_Nav_Agent_path_finished():
	var state = _a_Movement.get_state()
	match state:
		"Move_To_Flee_Pos":
			fled.emit()
			_emit_turn_completed()

func _on_Movement_Jump_jumped():
	_a_action_on_cd = false
	_a_States.set_state_tmp("Idle")
	_a_Anims.update_anim()
