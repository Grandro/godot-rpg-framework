@tool
extends MeshInstance3D

@export var _e_base_size: Vector3 = Vector3.ONE:
	set(p_value):
		_e_base_size = p_value
		_update()

@export var _e_offset : Vector3 = Vector3.ZERO:
	set(p_value):
		_e_offset = p_value
		_update()

@export var _e_size : Vector3 = Vector3.ONE:
	set(p_value):
		_e_size = p_value
		_update()

func _ready():
	if mesh == null:
		return
	
	set_mesh(mesh.duplicate())
	var mat = mesh.get_material()
	if mat == null:
		return
	
	mesh.set_material(mat.duplicate())
	_update()

func _update():
	if !is_node_ready():
		return
	if mesh == null:
		return
	
	var snapped_rotation = rotation.snappedf(deg_to_rad(90.0))
	var basis_ = Basis.from_euler(snapped_rotation)
	var basis_inverse = basis_.inverse()
	var new_size = (basis_inverse * _e_size).abs()
	var new_offset = (basis_inverse * _e_offset).abs()
	var mat = mesh.get_material()
	mat.set_uv1_scale(Vector3(new_size.x, new_size.z, 1.0))
	mat.set_uv1_offset(Vector3(new_offset.x, new_offset.z, 0.0))

func set_offset(p_offset):
	_e_offset = p_offset

func set_size(p_size):
	_e_size = p_size
