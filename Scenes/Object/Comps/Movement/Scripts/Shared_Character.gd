extends "res://Scenes/Object/Comps/Movement/Scripts/Shared_Base.gd"

func physics_process(_p_delta):
	_update_speed()
	
	_a_velocity = _a_entity.get_init_velocity()
	for child in _a_entity.get_children():
		_a_velocity += child.get_velocity_()
	for child in _a_entity.get_children():
		_a_velocity = child.adjust_velocity_post(_a_velocity)
	
	_a_entity_entity.set_velocity(_a_velocity)
	_a_entity_entity.move_and_slide()
