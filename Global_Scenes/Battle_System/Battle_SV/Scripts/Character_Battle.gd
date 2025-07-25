extends Character3DObject

signal action_started()
signal action_pre_event()
signal action_post_event()
signal turn_completed()
signal turn_canceled()
signal died()

@export_enum("Party_Member", "Enemy") var _e_type: String = "Party_Member"
@export var _e_popup_offset: Vector3 = Vector3.ZERO
@export var _e_attack_offset: Vector3 = Vector3.ZERO
@export var _e_rating_offset: Vector3 = Vector3.ZERO

@onready var _a_Hitbox = get_node("Hitbox")

var _a_encounter = null
var _a_actions_data = {}

var _a_target = null # Selected target
var _a_command = "" # Selected command key
var _a_special = "" # Selected special key
var _a_on_turn = false # Is on turn?
var _a_turn_completed = false # Has completed turn this round?

func _ready():
	super()
	var stats_comp = comph().get_comp("Stats")
	stats_comp.stat_changed.connect(_on_Stats_stat_changed)

func process_action_start():
	_a_on_turn = true
	action_started.emit()

func update_actions_data(p_actions):
	var actions_data = Databases.get_data("SV_Actions")
	for type in p_actions:
		_a_actions_data[type] = {}
		for key in p_actions[type]:
			_a_actions_data[type][key] = actions_data[type][key]

func _emit_turn_completed():
	_a_on_turn = false
	set_turn_completed(true)
	turn_completed.emit()

func _emit_turn_canceled():
	_a_on_turn = false
	turn_canceled.emit()

func _cutscene(p_key, p_entry_key, p_cb_method = Callable(), p_process_type = "Main",
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

func set_target(p_target):
	_a_target = p_target

func set_command(p_command):
	_a_command = p_command

func get_command():
	return _a_command

func set_special(p_special):
	_a_special = p_special

func get_curr_command_args():
	return _a_actions_data["Commands"][_a_command]

func get_specials_args():
	return _a_actions_data["Specials"]

func set_turn_completed(p_turn_completed):
	_a_turn_completed = p_turn_completed

func get_turn_completed():
	return _a_turn_completed

func _get_target_attack_pos():
	var pos = _a_target.get_global_position()
	var attack_offset = _a_target.get_attack_offset()
	var final_pos = pos + attack_offset
	
	return final_pos

func _on_Stats_stat_changed(p_stat, p_value):
	match p_stat:
		"HP":
			if p_value == 0:
				died.emit()
