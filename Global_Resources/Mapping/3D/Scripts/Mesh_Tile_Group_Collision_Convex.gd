@tool
extends "res://Global_Resources/Mapping/3D/Scripts/Mesh_Tile_Group_Collision_Base.gd"

var _a_base_points = PackedVector3Array()

func _ready():
	var shape = _a_Collision.get_shape()
	_a_base_points = shape.get_points()
	
	super()

func _update_collision_shape(p_shape, p_size):
	var points = PackedVector3Array()
	for base_point in _a_base_points:
		var point = base_point * p_size
		points.push_back(point)
	
	p_shape.set_points(points)
	_a_Collision.set_shape(p_shape)
