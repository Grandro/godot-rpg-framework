extends Node

@onready var _a_Idle_CD = get_node("Idle_CD")

var _a_entity = null
var _a_entity_comph : CompHandler = null
var _a_movement = null
var _a_movement_comph : CompHandler = null

var _a_velocity = null # Vector
var _a_can_jump = true

func _ready():
	_a_Idle_CD.timeout.connect(_on_Idle_CD_timeout)
	
	set_process_unhandled_input(_a_can_jump)

func _process(_p_delta):
	_check_idle()

func _physics_process(_p_delta):
	_process_move()
	_a_entity_comph.call_comp("Anims", "update_anim")

func _unhandled_input(p_event):
	if _a_entity.is_on_floor():
		if p_event.is_action_pressed("Jump"):
			_a_movement_comph.call_comp("Jump", "jump")

func init(p_entity):
	_a_entity = p_entity
	_a_entity_comph = _a_entity.comph()
	_a_movement = _a_entity_comph.get_comp("Movement")
	_a_movement_comph = _a_movement.comph()
	
	if _a_entity_comph.has_comp("Operate"):
		var operate_comp = _a_entity_comph.get_comp("Operate")
		operate_comp.to_disabled.connect(_on_Operate_to_disabled)
		operate_comp.to_enabled.connect(_on_Operate_to_enabled)

func _process_move():
	_a_velocity = _get_input_velocity()
	_a_velocity = _a_velocity.normalized()
	
	if _a_velocity.length() > 0.0:
		var dir = Global.get_vec_dir(_a_velocity)
		_a_movement.set_dir(dir)
	
	_change_state(_a_velocity)
	_a_velocity *= _a_movement.get_speed()

func _change_state(p_velocity):
	if p_velocity.length() > 0.0:
		if Input.is_action_pressed("Move_Run"):
			_a_entity_comph.call_comp("States", "set_state_tmp", ["Run"])
		else:
			_a_entity_comph.call_comp("States", "set_state_tmp", ["Walk"])
	else:
		var state_tmp = _a_entity_comph.call_comp("States", "get_state_tmp")
		if state_tmp != "Idle":
			_a_entity_comph.call_comp("States", "set_state_tmp", ["Stop"])

func _check_idle():
	var state_tmp = _a_entity_comph.call_comp("States", "get_state_tmp")
	if state_tmp == "Stop":
		if _a_Idle_CD.is_stopped():
			_a_Idle_CD.start()
	else:
		_a_Idle_CD.stop()

func set_can_jump(p_can_jump):
	_a_can_jump = p_can_jump
	set_process_unhandled_input(p_can_jump)

func reset_velocity():
	_a_velocity = _a_movement.get_init_velocity()

func adjust_velocity_post(p_velocity):
	return p_velocity

func get_velocity_():
	return _a_velocity

func get_speed():
	return 0.0

func _get_input_velocity():
	pass

func _is_on_floor():
	pass

func _on_Operate_to_disabled():
	set_process(false)
	set_physics_process(false)
	set_process_unhandled_input(false)
	reset_velocity()
	_a_Idle_CD.stop()
	_a_movement.stop()

func _on_Operate_to_enabled():
	set_process(true)
	set_physics_process(true)
	set_process_unhandled_input(_a_can_jump)
	_check_idle()

func _on_Idle_CD_timeout():
	_a_entity_comph.call_comp("States", "set_state_tmp", ["Idle"])
