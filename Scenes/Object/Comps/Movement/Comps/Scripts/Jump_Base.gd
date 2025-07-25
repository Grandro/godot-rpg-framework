extends Node

signal jumped()

@export var _e_speed: int = 15

var _a_entity = null
var _a_entity_comph : CompHandler = null
var _a_movement = null

var _a_gravity_vec = null # Vector
var _a_gravity = -1.0
var _a_velocity = null # Vector
var _a_init = false # Jump has been initialized, can still be on floor
var _a_active = false # Is in air while jumping

func _physics_process(p_delta):
	_process_gravity(p_delta)
	
	if _a_init && !_a_entity.is_on_floor():
		_a_active = true
		_a_init = false
	if _a_active && _a_entity.is_on_floor():
		_a_active = false
		jumped.emit()

func init(p_entity):
	_a_entity = p_entity
	_a_entity_comph = _a_entity.comph()
	_a_movement = _a_entity_comph.get_comp("Movement")
	
	var anims_comp = _a_entity_comph.get_comp("Anims")
	anims_comp.animation_finished.connect(_on_Anims_anim_finished)

func jump(p_speed = _e_speed):
	_a_init = true
	_a_velocity.y += p_speed
	
	_a_entity_comph.call_comp("States", "set_state_tmp", ["Jump"])
	_a_entity_comph.call_comp("Anims", "update_anim")
	_a_entity_comph.call_comp("Audio", "play", ["Jump"])

func _process_gravity(p_delta):
	if !_a_entity.is_on_floor():
		_a_velocity += _a_gravity_vec * _a_gravity * p_delta * 4
	else:
		reset_velocity()

func reset_velocity():
	_a_velocity = _a_movement.get_init_velocity()

func adjust_velocity_post(p_velocity):
	return p_velocity

func get_velocity_():
	return _a_velocity

func get_speed():
	return 0.0

func _on_Anims_anim_finished(p_anim_name):
	if "Jump" in p_anim_name:
		_a_entity_comph.call_comp("States", "set_state_tmp", ["Fall"])
		_a_entity_comph.call_comp("Anims", "update_anim")
