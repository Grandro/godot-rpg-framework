@tool
extends "res://Global_Resources/Mapping/3D/Scripts/Mesh_Tile_Group.gd"

@export var _e_coll_base_size : Vector3 = Vector3.ONE:
	set(p_value):
		_e_coll_base_size = p_value
		_update()

@onready var _a_Collision = get_node("Static/Collision")

func _update():
	if !is_node_ready():
		return
	
	super()
	
	var shape = _a_Collision.get_shape()
	if shape == null:
		return
	
	var shape_dup = shape.duplicate()
	var size = _e_size * _e_coll_base_size
	_update_collision_shape(shape_dup, size)

func _update_collision_shape(_p_shape, _p_size):
	pass
