extends "res://Scripts/Extension_Base.gd"

var _a_Free_Camera = null
var _a_Free_Audio = null

var _a_BGM : AudioPlayback = null
var _a_BGS : Array[AudioPlayback] = []

func ready():
	_a_Free_Camera = _a_entity.get_node("Objects/$Free_Camera")
	_a_Free_Audio = _a_entity.get_node("Objects/$Free_Audio")

func _play_BGM():
	var audio_manager_si = Global.get_singleton(_a_entity, "Audio_Manager")
	if _a_BGM == null:
		audio_manager_si.flatten_bgm()
		return
	
	var stream = _a_BGM.get_stream()
	var volume = _a_BGM.get_volume()
	var pitch = _a_BGM.get_pitch()
	var from = _a_BGM.get_from()
	var player = audio_manager_si.replace_bgm(stream, volume, pitch, from)
	audio_manager_si.flatten_bgm(player)

func _play_BGS():
	var audio_manager_si = Global.get_singleton(_a_entity, "Audio_Manager")
	var players = []
	for BGS in _a_BGS:
		var stream = BGS.get_stream()
		var volume = BGS.get_volume()
		var pitch = BGS.get_pitch()
		var from = BGS.get_from()
		var player = audio_manager_si.replace_bgs(stream, volume, pitch, from)
		players.push_back(player)
	audio_manager_si.flatten_bgs(players)

func get_free_camera():
	return _a_Free_Camera

func get_free_audio():
	return _a_Free_Audio

func set_BGM(p_BGM):
	_a_BGM = p_BGM

func set_BGS(p_BGS):
	_a_BGS = p_BGS

func get_save_data():
	var data = {}
	var global_si = Global.get_singleton(_a_entity, "Global")
	var camera_limit = global_si.get_camera_limit()
	data["Camera_Limit"] = camera_limit.duplicate()
	
	return data

func load_data(p_map_data):
	var global_si = Global.get_singleton(_a_entity, "Global")
	global_si.set_camera_limit(p_map_data["Curr_Scene"]["Camera_Limit"])

func load_data_init():
	_play_BGM()
	_play_BGS()
