extends "res://Scenes/Object/Comps/Movement/Comps/Scripts/Rigid_Collision_Base.gd"

func _is_instance_rigid_body(p_instance):
	return p_instance is RigidBody2D
