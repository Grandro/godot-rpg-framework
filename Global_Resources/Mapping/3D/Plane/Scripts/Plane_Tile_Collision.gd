@tool
extends "res://Global_Resources/Mapping/3D/Plane/Scripts/Plane_Tile.gd"

@onready var _a_Collision = get_node("Static/Collision")

func _update():
	if !is_node_ready():
		return
	
	super()
	
	var shape = _a_Collision.get_shape()
	var shape_dup = shape.duplicate()
	var size = _e_size * _e_base_size
	shape_dup.size.x = size.x
	shape_dup.size.z = size.z
	_a_Collision.set_shape(shape_dup)
