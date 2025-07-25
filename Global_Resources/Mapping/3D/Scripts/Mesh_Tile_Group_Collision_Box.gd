@tool
extends "res://Global_Resources/Mapping/3D/Scripts/Mesh_Tile_Group_Collision_Base.gd"

func _update_collision_shape(p_shape, p_size):
	p_shape.set_size(p_size)
	_a_Collision.set_shape(p_shape)
