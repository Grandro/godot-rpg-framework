extends Node3D

var _a_quad_mesh_size = Vector2.ZERO
var _a_mouse_inside = false
var _a_mouse_held = false
var _a_last_mouse_pos_3D = null
var _a_last_mouse_pos_2D = null

@onready var _a_Plane = get_node("Plane")
@onready var _a_Area = get_node("Plane/Area")
@onready var _a_VP = get_node("VP")

func _ready():
	_a_Area.mouse_entered.connect(_on_Area_mouse_entered)
	
	var mesh = _a_Plane.get_mesh()
	var mat = mesh.get_material()
	var billboard_mode = mat.get_billboard_mode()
	if billboard_mode == BaseMaterial3D.BILLBOARD_DISABLED:
		set_process(false)

func _process(_p_delta):
	_rotate_area_to_billboard()

func _unhandled_input(p_event):
	var mouse_event = (
		p_event is InputEventMouse or
		p_event is InputEventScreenDrag or
		p_event is InputEventScreenTouch
	)
	
	if mouse_event && (_a_mouse_inside || _a_mouse_held):
		# Additional processing
		_handle_mouse(p_event)
	elif !mouse_event:
		_a_VP.push_input(p_event)

func _handle_mouse(p_event):
	if p_event is InputEventMouseButton || p_event is InputEventScreenTouch:
		_a_mouse_held = p_event.is_pressed()
	
	var mouse_pos_3D = _find_mouse(p_event.global_position)
	_a_mouse_inside = mouse_pos_3D != null
	if _a_mouse_inside:
		mouse_pos_3D = _a_Area.global_transform.affine_inverse() * mouse_pos_3D
		_a_last_mouse_pos_3D = mouse_pos_3D
	else:
		mouse_pos_3D = _a_last_mouse_pos_3D
		if mouse_pos_3D == null:
			mouse_pos_3D = Vector3.ZERO
	
	var mesh_size = _a_Plane.mesh.size
	var mouse_pos_2D = Vector2(mouse_pos_3D.x, -mouse_pos_3D.y)
	# (-quad_size/2) -> (quad_size/2) to 0 -> quad_size
	mouse_pos_2D.x += mesh_size.x / 2
	mouse_pos_2D.y += mesh_size.y / 2
	# 0 -> quad_size to 0 -> 1
	mouse_pos_2D.x = mouse_pos_2D.x / mesh_size.x
	mouse_pos_2D.y = mouse_pos_2D.y / mesh_size.y
	# 0 -> 1 to 0 -> _a_Viewport.size
	mouse_pos_2D.x = mouse_pos_2D.x * _a_VP.size.x
	mouse_pos_2D.y = mouse_pos_2D.y * _a_VP.size.y
	
	p_event.set_position(mouse_pos_2D)
	p_event.set_global_position(mouse_pos_2D)
	
	if p_event is InputEventMouseMotion:
		if _a_last_mouse_pos_2D == null:
			p_event.set_relative(Vector2.ZERO)
		else:
			p_event.set_relative(mouse_pos_2D - _a_last_mouse_pos_2D)
	_a_last_mouse_pos_2D = mouse_pos_2D
	
	_a_VP.push_input(p_event)

func _find_mouse(p_global_position):
	var camera = get_viewport().get_camera_3d()
	var from = camera.project_ray_origin(p_global_position)
	var dist = _find_further_distance_to(camera.transform.origin)
	var to = from + camera.project_ray_normal(p_global_position) * dist
	var params = PhysicsRayQueryParameters3D.create(from, to, _a_Area.collision_layer)
	params.set_collide_with_areas(true)
	params.set_collide_with_bodies(false)
	var res = get_world_3d().direct_space_state.intersect_ray(params)
	if res.size() > 0:
		return res["position"]
	else:
		return null

func _find_further_distance_to(p_origin):
	var edges = []
	var top_right = Vector3(_a_quad_mesh_size.x / 2, _a_quad_mesh_size.y / 2, 0)
	var bottom_right = Vector3(_a_quad_mesh_size.x / 2, -_a_quad_mesh_size.y / 2, 0)
	var top_left = Vector3(-_a_quad_mesh_size.x / 2, _a_quad_mesh_size.y / 2, 0)
	var bottom_left = Vector3(-_a_quad_mesh_size.x / 2, -_a_quad_mesh_size.y / 2, 0)
	edges.push_back(_a_Area.to_global(top_right))
	edges.push_back(_a_Area.to_global(bottom_right))
	edges.push_back(_a_Area.to_global(top_left))
	edges.push_back(_a_Area.to_global(bottom_left))
	
	var far_dist = 0
	for edge in edges:
		var temp_dist = p_origin.distance_to(edge)
		if temp_dist > far_dist:
			far_dist = temp_dist
	
	return far_dist

func _rotate_area_to_billboard():
	var mesh = _a_Plane.get_mesh()
	var mat = mesh.get_material()
	var billboard_mode = mat.get_billboard_mode()
	var camera = get_viewport().get_camera_3d()
	var look = camera.to_global(Vector3(0, 0, -100)) - camera.global_transform.origin
	look += _a_Area.position
	
	if billboard_mode == BaseMaterial3D.BILLBOARD_FIXED_Y:
		look.y = 0
	
	_a_Area.look_at(look, Vector3.UP)
	_a_Area.rotate_object_local(Vector3.BACK, camera.rotation.z)

func _on_Area_mouse_entered():
	_a_mouse_inside = true
