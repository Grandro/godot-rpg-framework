extends Node

var _a_entity : Node = null
var _a_entity_comph : CompHandler = null

var _a_global_si = null

var _a_walk_in = {} # Match area to body
var _a_press_key = {} # Match area to body
var _a_body = null # Current best interaction body
var _a_area = null # Current best interaction area

func _ready():
	_a_global_si = Global.get_singleton(self, "Global")

func _physics_process(_delta):
	_update_interaction()

func init(p_entity):
	_a_entity = p_entity
	_a_entity_comph = p_entity.comph()

func _update_interaction():
	var entity_pos = _a_entity_comph.call_comp("Interactions", "get_default_interaction_pos")
	var entity_dir = _a_entity_comph.call_comp("Movement", "get_dir")
	for area in _a_walk_in:
		var body = _a_walk_in[area]
		var interaction_allowed = body.comph().call_comp("Interactions", "get_interaction_allowed")
		if !interaction_allowed:
			continue
		
		if body.comph().has_comp("Cutscene"):
			var is_in_cutscene = body.comph().call_comp("Cutscene", "is_in_cutscene")
			var is_disabled_by_cutscene = body.comph().call_comp("Cutscene", "is_disabled_by_cutscene")
			if is_in_cutscene || is_disabled_by_cutscene:
				continue
		
		var dirs = area.get_dirs()
		if !dirs.has(entity_dir):
			continue
		
		var area_pos = area.get_global_position()
		var match_dir = area.get_match_dir()
		if match_dir:
			var face_dir = Global.get_dir_to_pos(entity_pos, area_pos)
			if entity_dir != face_dir:
				continue
		
		body.comph().call_comp("Interactions", "interaction", [area])
	
	var best_body = null
	var best_area = null
	var best_distance = -1.0
	for area in _a_press_key:
		var body = _a_press_key[area]
		var interaction_allowed = body.comph().call_comp("Interactions", "get_interaction_allowed")
		if !interaction_allowed:
			continue
		
		if body.comph().has_comp("Cutscene"):
			var is_in_cutscene = body.comph().call_comp("Cutscene", "is_in_cutscene")
			var is_disabled_by_cutscene = body.comph().call_comp("Cutscene", "is_disabled_by_cutscene")
			if is_in_cutscene || is_disabled_by_cutscene:
				continue
		
		var dirs = area.get_dirs()
		if !dirs.has(entity_dir):
			continue
		
		var area_pos = area.get_global_position()
		var match_dir = area.get_match_dir()
		if match_dir:
			var face_dir = Global.get_dir_to_pos(entity_pos, area_pos)
			if entity_dir != face_dir:
				continue
		
		var distance = entity_pos.distance_to(area_pos)
		if best_area == null:
			best_body = body
			best_area = area
			best_distance = distance
		elif distance < best_distance:
			best_body = body
			best_area = area
			best_distance = distance
	
	if _a_area != best_area:
		_set_interaction(best_body, best_area)

func _set_interaction(p_body, p_area):
	if is_instance_valid(_a_body):
		_a_body.comph().call_comp("Interactions", "interaction_deactivate", [_a_area])
	if is_instance_valid(p_body):
		var entity_dir = _a_entity_comph.call_comp("Movement", "get_dir")
		p_body.comph().call_comp("Interactions", "interaction_activate", [p_area, entity_dir])
	
	_a_body = p_body
	_a_area = p_area

func get_body():
	return _a_body

func get_area():
	return _a_area

func get_save_data():
	return {}

func load_data(_p_data):
	pass

func load_data_init():
	pass

func _on_Interaction_area_entered(p_area):
	var interactions_comp = p_area.get_parent()
	var body = interactions_comp.get_entity()
	var type = p_area.get_type()
	match type:
		"Walk_In": _a_walk_in[p_area] = body
		"Press_Key": _a_press_key[p_area] = body

func _on_Interaction_area_exited(p_area):
	var type = p_area.get_type()
	match type:
		"Walk_In": _a_walk_in.erase(p_area)
		"Press_Key": _a_press_key.erase(p_area)
