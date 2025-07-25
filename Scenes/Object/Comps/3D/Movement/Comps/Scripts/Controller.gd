extends "res://Scenes/Object/Comps/Movement/Comps/Scripts/Controller_Base.gd"

func _init():
	_a_velocity = Vector3.ZERO

func _get_input_velocity():
	var velocity = Input.get_vector("Move_Left", "Move_Right", "Move_Up", "Move_Down")
	velocity = Vector3(velocity.x, 0.0, velocity.y)
	
	return velocity

func _is_on_floor():
	return _a_entity.is_on_floor()
