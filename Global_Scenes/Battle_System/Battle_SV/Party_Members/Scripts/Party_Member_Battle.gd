extends "res://Global_Scenes/Battle_System/Battle_SV/Character_Battle/Scripts/Character_Battle.gd"

@export var _e_command_circle_offset: Vector3 = Vector3.ZERO
@export var _e_reactions: Dictionary = {} # Match reaction key to button

@onready var _a_Audio = get_node("Audio")
@onready var _a_Movement_Jump = get_node("Movement/Jump")
@onready var _a_Shield_Bar = get_node("Shield_Bar")

var _a_actions = {}
var _a_action_on_cd = false # Is action on CD?
var _a_action_time = 0.0 # Action timestamp
var _a_action_dif = 0.0 # Action timing difference

func _ready():
	super()
	_a_Movement_Jump.jumped.connect(_on_Movement_Jump_jumped)
	
	set_process_unhandled_input(false)

func _unhandled_input(p_event):
	if _a_action_on_cd:
		return
	
	if _a_on_turn:
		_process_action_event(p_event)
	else:
		_process_reaction_event(p_event)

func process_action_start():
	super()
	_process_action_start()

func process_dmg(p_dmg):
	match _a_command:
		"Defense_DEF":
			var time = Time.get_ticks_msec() / 1000.0
			_a_action_dif = time - _a_action_time
			var rating = get_timing_rating()
			_a_encounter.display_rating(self, rating)
			
			var defense_fac = _get_defense_fac(rating)
			var dmg = int(p_dmg / defense_fac)
			_a_Stats.decrease_curr_stat("HP", dmg)
			
			var shield_gain = _get_shield_gain(rating)
			_a_Shield_Bar.open(shield_gain)
		_:
			super(p_dmg)

func reaction_start():
	_a_action_on_cd = false
	_a_action_dif = 0.0
	set_process_unhandled_input(true)

func reaction_end():
	set_process_unhandled_input(false)
	_a_States.set_state_tmp("Idle")
	_a_Anims.update_anim()

func _process_action_start():
	match _a_command:
		"Special": _a_Actions.process_special(_a_special)
		_: _a_Actions.process_command(_a_command)

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
	_a_Actions.update_data(p_actions)

func get_enabled_actions(p_type):
	var enabled = []
	for key in _a_actions[p_type]:
		var state = _a_actions[p_type][key]
		if state == "Enabled":
			enabled.push_back(key)
	
	return enabled

func set_action_on_cd(p_action_on_cd):
	_a_action_on_cd = p_action_on_cd

func set_action_dif(p_action_dif):
	_a_action_dif = p_action_dif

func get_timing_rating():
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

func _on_Movement_Jump_jumped():
	_a_action_on_cd = false
	_a_States.set_state_tmp("Idle")
	_a_Anims.update_anim()

func _on_Anims_anim_finished(p_name):
	if "Duck" in p_name:
		_a_action_on_cd = false
		_a_States.set_state_tmp("Idle")
		_a_Anims.update_anim()
