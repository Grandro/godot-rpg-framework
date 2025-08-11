extends "res://Global_Scenes/Battle_System/Battle_SV/Character_Battle/Comps/Actions/Scripts/Action_Base.gd"

var _a_Audio = null
var _a_Movement = null
var _a_Movement_Nav_Agent = null
var _a_States = null
var _a_Anims = null

var _a_encounter = null

func init(p_commands, p_entity):
	super(p_commands, p_entity)
	_a_Audio = p_entity.comph().get_comp("Audio")
	_a_Movement = p_entity.comph().get_comp("Movement")
	_a_Movement_Nav_Agent = p_entity.comph().get_subcomp("Movement", "Nav_Agent")
	_a_States = p_entity.comph().get_comp("States")
	_a_Anims = p_entity.comph().get_comp("Anims")
	_a_encounter = p_entity.get_encounter()
	
	_a_Movement_Nav_Agent.path_finished.connect(_on_Movement_Nav_Agent_path_finished)

func process():
	started.emit()
	
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
	
	pre_event.emit()
	if pm_avg_SPEED >= enemies_avg_SPEED:
		_process_success(party_members)
	else:
		_process_fail()
	post_event.emit()

func _process_success(p_party_members):
	var flee_pos = _a_encounter.get_flee_pos()
	for instance in p_party_members.values():
		var pos = instance.get_global_position()
		flee_pos = Vector3(flee_pos.x, pos.y, pos.z)
		
		_a_Audio.play("Flee")
		_a_States.set_state("Walk")
		_a_Movement.set_state("Move_To_Flee_Pos")
		_a_Movement.move_to_pos(flee_pos)
		_a_Anims.update_anim()

func _process_fail():
	pass

func _on_Movement_Nav_Agent_path_finished():
	var state = _a_Movement.get_state()
	match state:
		"Move_To_Flee_Pos":
			_finished()
