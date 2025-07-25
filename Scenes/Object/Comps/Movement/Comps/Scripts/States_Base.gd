extends Node

@export var _e_speeds : Dictionary[String, float] = {} # Match state to speed

var _a_movement = null

var _a_speed = 0.0

func init(p_entity):
	var entity_comph = p_entity.comph()
	_a_movement = entity_comph.get_comp("Movement")
	
	var states_comp = entity_comph.get_comp("States")
	states_comp.state_tmp_changed.connect(_on_States_state_tmp_changed)

func reset_velocity():
	pass

func adjust_velocity_post(p_velocity):
	return p_velocity

func get_velocity_():
	return _a_movement.get_init_velocity()

func get_speed():
	return _a_speed

func _on_States_state_tmp_changed(p_state_tmp):
	if _e_speeds.has(p_state_tmp):
		_a_speed = _e_speeds[p_state_tmp]
