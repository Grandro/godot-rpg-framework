extends "res://Scripts/Extension_Base.gd"

var _a_Audio = null
var _a_Veil = null

var _a_audio_base_path = "" # (String, DIR)
var _a_veil_base_path = "" # (String, DIR)
var _a_areas = []

func ready():
	_a_Audio = _a_entity.get_node("Audio")
	_a_Veil = _a_entity.get_node("Veil")
	
	_a_entity.area_entered.connect(_on_Entity_area_entered)
	_a_entity.area_exited.connect(_on_Entity_area_exited)
	
	_a_Veil.set_texture(null)

func play_audio():
	_update_audio_stream()
	_a_Audio.play()

func _update_audio_stream():
	var stream = null
	if !_a_areas.is_empty():
		var area = _a_areas[-1]
		var audio_keys = area.get_audio_keys()
		var rndm_idx = randi() % audio_keys.size()
		var rndm_key = audio_keys[rndm_idx]
		stream = load("%s/%s.wav" % [_a_audio_base_path, rndm_key])
	
	_a_Audio.set_stream(stream)

func _update_veil_texture():
	var texture = null
	if !_a_areas.is_empty():
		var area = _a_areas[-1]
		var veil_key = area.get_veil_key()
		if !veil_key.is_empty():
			texture = load("%s/%s.png" % [_a_veil_base_path, veil_key])
	
	_a_Veil.set_texture(texture)

func set_audio_base_path(p_audio_base_path):
	_a_audio_base_path = p_audio_base_path

func set_veil_base_path(p_veil_base_path):
	_a_veil_base_path = p_veil_base_path

func get_areas():
	return _a_areas

func _on_Entity_area_entered(p_area):
	_a_areas.push_back(p_area)
	_update_veil_texture()

func _on_Entity_area_exited(p_area):
	_a_areas.erase(p_area)
	_update_veil_texture()
