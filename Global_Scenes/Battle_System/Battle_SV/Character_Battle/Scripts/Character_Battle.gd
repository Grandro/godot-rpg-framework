extends Character3DObject

signal action_started()
signal action_finished()
signal action_canceled()
signal action_pre_event()
signal action_post_event()
signal hit(p_target)
signal died()

@export_enum("Party_Member", "Enemy") var _e_type: String = "Party_Member"
@export var _e_move_state: String = "Walk"
@export var _e_popup_offset: Vector3 = Vector3.ZERO
@export var _e_attack_offset: Vector3 = Vector3.ZERO
@export var _e_rating_offset: Vector3 = Vector3.ZERO

@onready var _a_Movement = get_node("Movement")
@onready var _a_Movement_Nav_Agent = get_node("Movement/Nav_Agent")
@onready var _a_Movement_Knockbacks = get_node("Movement/Knockbacks")
@onready var _a_Actions = get_node("Actions")
@onready var _a_States = get_node("States")
@onready var _a_Stats = get_node("Stats")
@onready var _a_Anims = get_node("Anims")

var _a_encounter = null

var _a_target = null # Selected target
var _a_command = "" # Selected command key
var _a_special = "" # Selected special key
var _a_on_turn = false # Is on turn?
var _a_turn_completed = false # Has completed turn this round?

func _ready():
	super()
	_a_Movement_Nav_Agent.path_finished.connect(_on_Movement_Nav_Agent_path_finished)
	_a_Movement_Knockbacks.started.connect(_on_Movement_Knockbacks_started)
	_a_Movement_Knockbacks.finished.connect(_on_Movement_Knockbacks_finished)
	_a_Actions.started.connect(_on_Actions_started)
	_a_Actions.finished.connect(_on_Actions_finished)
	_a_Actions.pre_event.connect(_on_Actions_pre_event)
	_a_Actions.post_event.connect(_on_Actions_post_event)
	_a_Actions.hit.connect(_on_Actions_hit)
	_a_Anims.animation_finished.connect(_on_Anims_anim_finished)

func process_action_start():
	_a_on_turn = true
	action_started.emit()

func process_dmg(p_dmg):
	_a_Stats.decrease_curr_stat("HP", p_dmg)

func _emit_action_finished():
	_a_on_turn = false
	set_turn_completed(true)
	action_finished.emit()

func _emit_action_canceled():
	_a_on_turn = false
	action_canceled.emit()

func cutscene(p_key, p_entry_key, p_cb_method = Callable(), p_process_type = "Main",
			  p_key_type = "Map"):
	var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
	cutscene_system_si.cutscene(p_key, p_entry_key, p_process_type, p_key_type)
	cutscene_system_si.set_cutscene_completed_cb(p_key, p_entry_key, p_cb_method)

func get_type():
	return _e_type

func get_popup_offset():
	return _e_popup_offset

func get_attack_offset():
	return _e_attack_offset

func get_rating_offset():
	return _e_rating_offset

func set_encounter(p_encounter):
	_a_encounter = p_encounter

func get_encounter():
	return _a_encounter

func set_target(p_target):
	_a_target = p_target

func get_target():
	return _a_target

func set_command(p_command):
	_a_command = p_command

func get_command():
	return _a_command

func set_special(p_special):
	_a_special = p_special

func get_curr_command_arg():
	return _a_Actions.get_commands_arg(_a_command)

func set_turn_completed(p_turn_completed):
	_a_turn_completed = p_turn_completed

func get_turn_completed():
	return _a_turn_completed

func get_target_attack_pos():
	var pos = _a_target.get_global_position()
	var attack_offset = _a_target.get_attack_offset()
	var final_pos = pos + attack_offset
	
	return final_pos

func _on_Movement_Nav_Agent_path_finished():
	var state = _a_Movement.get_state()
	match state:
		"Recover_Knockback":
			_a_States.set_state("Idle")
			_a_Movement.reset_dir()
			_a_Anims.update_anim()

func _on_Movement_Knockbacks_started():
	_a_States.set_state_tmp("Knockback")
	_a_Anims.update_anim()

func _on_Movement_Knockbacks_finished():
	await get_tree().create_timer(0.3).timeout
	var HP = _a_Stats.get_curr_stat("HP")
	if HP == 0:
		_a_States.set_state_tmp("Die")
	else:
		_a_States.set_state_tmp(_e_move_state)
		_a_Movement.set_state("Recover_Knockback")
		_a_Movement.move_to_org_pos()
	_a_Anims.update_anim()

func _on_Actions_started():
	action_started.emit()

func _on_Actions_finished():
	_emit_action_finished()

func _on_Actions_pre_event():
	action_pre_event.emit()

func _on_Actions_post_event():
	action_post_event.emit()

func _on_Actions_hit():
	hit.emit(_a_target)

func _on_Anims_anim_finished(p_name):
	if "Die" in p_name:
		died.emit()
