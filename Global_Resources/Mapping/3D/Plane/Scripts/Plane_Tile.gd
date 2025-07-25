@tool
extends "res://Global_Resources/Mapping/3D/Scripts/Mesh_Tile_Base.gd"

func _update():
	if !is_node_ready():
		return
	if mesh == null:
		return
	
	super()
	
	var size = _e_size * _e_base_size
	var snapped_rotation = rotation.snappedf(deg_to_rad(90.0))
	var basis_ = Basis.from_euler(snapped_rotation)
	size = (basis_.inverse() * size).abs()
	mesh.set_size(Vector2(size.x, size.z))
