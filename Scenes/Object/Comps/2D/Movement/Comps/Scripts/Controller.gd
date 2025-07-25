extends "res://Scenes/Object/Comps/Movement/Comps/Scripts/Controller_Base.gd"

func _init():
	_a_velocity = Vector2.ZERO

func _get_input_velocity():
	return Input.get_vector("Move_Left", "Move_Right", "Move_Up", "Move_Down")

func _is_on_floor():
	return true
