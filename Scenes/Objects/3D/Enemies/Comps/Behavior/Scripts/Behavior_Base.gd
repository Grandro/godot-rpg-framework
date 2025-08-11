extends Node3D

@export var _e_idle_cd: float = 1.0

@onready var _a_Debug_State = get_node("Debug_State")
@onready var _a_Debug_Keep_State = get_node("Debug_Keep_State")

@onready var _a_Target_Range = get_node("Target_Range")
@onready var _a_States = get_node("States")
@onready var _a_State_CD = get_node("State_CD")
@onready var _a_Idle_CD = get_node("Idle_CD")

var _a_entity : Character3DObject = null
var _a_entity_comph : CompHandler = null

var _a_states = {} # Map state to instance
var _a_stay_area = null
var _a_target = null
var _a_state = ""
var _a_queued_state = ""
var _a_keep_state = false

func _process(_p_delta):
	if !_a_keep_state && !_a_queued_state.is_empty():
		_set_state(_a_queued_state)
		_set_queued_state("")

func init(p_entity):
	_a_entity = p_entity
	_a_entity_comph = p_entity.comph()
	_a_entity_comph.comps_registered.connect(_on_Comp_Handler_comps_registered)
	
	_a_stay_area = p_entity.get_stay_area()

func _process_state():
	var instance = _a_states[_a_state]
	instance.process_start()
	
	var keep_state = instance.get_keep_state()
	_set_keep_state(keep_state)

func get_stay_area():
	return _a_stay_area

func get_target():
	return _a_target

func get_state():
	return _a_state

func get_keep_state():
	return _a_keep_state

func _set_state(p_state, p_process = true):
	if !_a_state.is_empty():
		var instance = _a_states[_a_state]
		instance.process_end()
	
	_a_state = p_state
	
	_a_Debug_State.set_text(p_state)
	_a_State_CD.stop()
	_a_Idle_CD.stop()
	
	if p_process:
		_process_state()

func _set_queued_state(p_queued_state):
	_a_queued_state = p_queued_state

func _set_keep_state(p_keep_state):
	_a_keep_state = p_keep_state
	_a_Debug_Keep_State.set_text(str(p_keep_state))

func get_save_data():
	var data = {}
	data["State"] = _a_state
	
	return data

func load_data(p_data):
	var state = p_data["State"]
	match state:
		"In_Battle":
			_set_state("Respawn")
		
		"Respawn":
			var progress_si = Global.get_singleton(self, "Progress")
			var key = _a_entity_comph.call_comp("Reference", "get_key")
			var respawn_rdy = progress_si.call_object(key, "get_respawn_rdy")
			if respawn_rdy:
				_set_state("Rndm")
				_a_entity.show()
			else:
				_set_state("Respawn", false)
		
		_:
			_set_state(state)

func load_data_init():
	pass

func _on_Comp_Handler_comps_registered():
	_a_Target_Range.body_entered.connect(_on_Target_Range_body_entered)
	_a_Target_Range.body_exited.connect(_on_Target_Range_body_exited)
	_a_State_CD.timeout.connect(_on_State_CD_timeout)
	_a_Idle_CD.timeout.connect(_on_Idle_CD_timeout)
	
	var battle_starter_comp = _a_entity_comph.get_comp("Battle_Starter")
	var global_si = Global.get_singleton(self, "Global")
	battle_starter_comp.battle_starting.connect(_on_Battle_Starter_battle_starting)
	_a_target = global_si.get_player()
	
	for child in _a_States.get_children():
		var state = child.get_name()
		child.processed.connect(_on_State_processed.bind(state))
		child.init(self, _a_entity, _a_entity_comph)
		child.register(_a_states)

func _on_State_processed(p_state):
	var instance = _a_states[p_state]
	var use_CD = instance.get_use_CD()
	if use_CD:
		var CD = instance.get_CD()
		if CD == 0.0:
			_set_state(p_state)
			return
		_a_State_CD.start(CD)
	
	if !_a_keep_state:
		_a_Idle_CD.start(_e_idle_cd)

func _on_Target_Range_body_entered(_p_body):
	pass

func _on_Target_Range_body_exited(_p_body):
	pass

func _on_State_CD_timeout():
	_set_state(_a_state)

func _on_Idle_CD_timeout():
	_a_entity_comph.call_comp("States", "set_state", ["Idle"])
	_a_entity_comph.call_comp("Anims", "update_anim")

func _on_Battle_Starter_battle_starting():
	_a_entity_comph.call_comp("States", "set_state", ["Stop"])
	_a_entity_comph.call_comp("Anims", "update_anim")
	
	_set_state("In_Battle")
	_a_entity.hide()
