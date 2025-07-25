extends "res://Scripts/Extension_Base.gd"

var _a_Areas = null

var _a_entity_entity_comph = null
var _a_movement = null

var _a_audio_base_path = "" # (String, DIR)
var _a_veil_base_path = "" # (String, DIR)

func init(p_entity_entity):
	_a_entity_entity_comph = p_entity_entity.comph()
	_a_movement = _a_entity_entity_comph.get_comp("Movement")
	
	_a_entity_entity_comph.comps_registered.connect(_on_Entity_Entity_Comph_comps_registered)
	
	reset_velocity()

func ready():
	_a_Areas = _a_entity.get_node("Areas")
	
	for child in _a_Areas.get_children():
		child.set_audio_base_path(_a_audio_base_path)
		child.set_veil_base_path(_a_veil_base_path)

func play_audio(p_key):
	var instance = _a_Areas.get_node(p_key)
	instance.play_audio()

func set_audio_base_path(p_audio_base_path):
	_a_audio_base_path = p_audio_base_path

func set_veil_base_path(p_veil_base_path):
	_a_veil_base_path = p_veil_base_path

func reset_velocity():
	pass

func adjust_velocity_post(p_velocity):
	var children = _a_Areas.get_children()
	var last_areas = []
	for child in children:
		var areas = child.get_areas()
		if !areas.is_empty():
			last_areas.push_back(areas[-1])
	
	if last_areas.is_empty():
		return p_velocity
	
	var speed_mult = 0.0
	for last_area in last_areas:
		speed_mult += last_area.get_speed_mult()
	speed_mult /= last_areas.size()
	
	return p_velocity * speed_mult

func get_velocity():
	return _a_movement.get_init_velocity()

func get_speed():
	return 0.0

func _on_Entity_Entity_Comph_comps_registered():
	if _a_entity_entity_comph.has_comp_subcomp("Movement", "Jump"):
		var jump_comp = _a_entity_entity_comph.get_subcomp("Movement", "Jump")
		jump_comp.jumped.connect(_on_Movement_Jump_jumped)

func _on_Movement_Jump_jumped():
	for child in _a_Areas.get_children():
		child.play_audio()
