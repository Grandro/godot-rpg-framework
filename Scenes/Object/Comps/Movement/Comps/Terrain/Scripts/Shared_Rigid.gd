extends "res://Scenes/Object/Comps/Movement/Comps/Terrain/Scripts/Shared_Base.gd"

var _a_entity_entity = null
var _a_last_audio_pos = null # Vector

func init(p_entity_entity):
	super(p_entity_entity)
	_a_entity_entity = p_entity_entity
	p_entity_entity.body_entered.connect(_on_Entity_Entity_body_entered)
	
	_a_last_audio_pos = p_entity_entity.get_global_position()

func physics_process():
	var global_pos = _a_entity_entity.get_global_position()
	var to_vec = _a_last_audio_pos - global_pos
	if to_vec.length() < 1.0:
		return
	
	for child in _a_Areas.get_children():
		child.play_audio()
	_a_last_audio_pos = global_pos

func _on_Entity_Entity_body_entered(_p_body):
	for child in _a_Areas.get_children():
		child.play_audio()
