extends "res://Scenes/Object/Comps/Movement/Scripts/Shared_Base.gd"

func integrate_forces(p_state):
	_update_speed()
	
	var linear_velocity = p_state.get_linear_velocity()
	_a_velocity = linear_velocity
	for child in _a_entity.get_children():
		_a_velocity += child.get_velocity_()
	for child in _a_entity.get_children():
		_a_velocity = child.adjust_velocity_post(_a_velocity)
	
	var central_force = _a_velocity - linear_velocity
	p_state.apply_central_force(central_force * 0.2)
