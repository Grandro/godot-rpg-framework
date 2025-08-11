extends Node3D

@export var _e_range : float = 10.0

var _a_entity : Character3DObject = null
var _a_entity_comph : CompHandler = null

var _a_enabled = 0 # 0 = disabled, >0 = enabled

func init(p_entity):
	_a_entity = p_entity
	_a_entity_comph = p_entity.comph()
	
	var target_pos = Vector3(0.0, 0.0, 1.0) * _e_range
	for child in get_children():
		child.set_target_position(target_pos)

func enable():
	_a_enabled += 1
	if _a_enabled == 1:
		_set_enabled(true)

func disable():
	_a_enabled -= 1
	if _a_enabled == 0:
		_set_enabled(false)

func _update_rotation_deg(p_dir):
	var dir_rotation_deg = Global.get_dir_rotation_deg(p_dir)
	set_rotation_degrees(dir_rotation_deg)

func can_see_instance(p_instance):
	var entity_pos = _a_entity.get_global_position()
	var pos = p_instance.get_global_position()
	if entity_pos.distance_to(pos) > _e_range:
		return false
	
	for child in get_children():
		if !child.is_colliding():
			continue
		
		var collider = child.get_collider()
		if collider == p_instance:
			return true
	
	return false

func _set_enabled(p_enabled):
	if _a_entity_comph.has_comp("Movement"):
		var movement_comp = _a_entity_comph.get_comp("Movement")
		if p_enabled:
			movement_comp.dir_changed.connect(_on_Movement_dir_changed)
		else:
			movement_comp.dir_changed.disconnect(_on_Movement_dir_changed)
	
	if p_enabled:
		var dir = _a_entity_comph.call_comp("Movement", "get_dir")
		_update_rotation_deg(dir)
	
	for child in get_children():
		child.set_enabled(p_enabled)

func get_save_data():
	var data = {}
	data["Range"] = _e_range
	data["Enabled"] = _a_enabled
	
	return data

func load_data(p_data):
	await _a_entity_comph.comps_registered
	
	_e_range = p_data["Range"]
	_a_enabled = p_data["Enabled"]
	for child in get_children():
		child.set_enabled(_a_enabled > 0)

func load_data_init():
	await _a_entity_comph.comps_registered
	
	for child in get_children():
		child.set_enabled(false)

func _on_Movement_dir_changed(p_dir):
	_update_rotation_deg(p_dir)
