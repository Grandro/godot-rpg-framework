extends Node

signal bgm_finished(p_file_name)
signal sfx_finished(p_file_name)
signal bgs_finished(p_file_name)

var _a_Pauseable_Audio_Scene = preload("res://Scenes/Pausable_Audio/Pausable_Audio.tscn")

@onready var _a_BGM = get_node("BGM")
@onready var _a_SFX = get_node("SFX")
@onready var _a_BGS = get_node("BGS")

var _a_save_data = {}

var _a_bgm = {} # Match file_name to array of player instances
var _a_bgs = {} # Match file_name to array of player instances

func play_bgm(p_stream, p_volume = 1.0, p_pitch = 1.0, p_from = 0.0):
	var path = p_stream.get_path()
	var file_name = path.get_file()
	var player = _a_Pauseable_Audio_Scene.instantiate()
	player.finished.connect(_on_BGM_finished.bind(player))
	player.tree_exited.connect(_on_BGM_tree_exited.bind(file_name))
	player.set_stream(p_stream)
	player.set_volume_db(linear_to_db(p_volume))
	player.set_pitch_scale(p_pitch)
	player.set_bus("BGM")
	player.set_name(file_name)
	player.play.call_deferred(p_from)
	
	if !_a_bgm.has(file_name):
		_a_bgm[file_name] = []
	_a_bgm[file_name].push_back(player)
	
	_set_last_bgm_stream_paused(true)
	
	_a_BGM.add_child(player)
	
	return player

func replace_bgm(p_stream, p_volume = 1.0, p_pitch = 1.0, p_from = 0.0):
	var path = p_stream.get_path()
	var file_name = path.get_file()
	var player = null
	if _a_bgm.has(file_name):
		player = _a_bgm[file_name][-1]
	
	if player == null:
		player = play_bgm(p_stream, p_volume, p_pitch, p_from)
	else:
		player.set_volume_db(linear_to_db(p_volume))
		player.set_pitch_scale(p_pitch)
	
	return player

func flatten_bgm(p_except = null):
	for child in _a_BGM.get_children():
		if child == p_except:
			continue
		_a_BGM.remove_child(child)
		child.queue_free()

func stop_bgm(p_file_name):
	var players = _a_bgm[p_file_name]
	var player = players[-1]
	_a_BGM.remove_child(player)
	player.queue_free()

func play_bgs(p_stream, p_volume = 1.0, p_pitch = 1.0, p_from = 0.0):
	var path = p_stream.get_path()
	var file_name = path.get_file()
	var player = AudioStreamPlayer.new()
	player.finished.connect(_on_BGS_finished.bind(player))
	player.tree_exited.connect(_on_BGS_tree_exited.bind(file_name))
	player.set_stream(p_stream)
	player.set_volume_db(linear_to_db(p_volume))
	player.set_pitch_scale(p_pitch)
	player.set_bus("BGS")
	player.set_name(file_name)
	player.play.call_deferred(p_from)
	
	if !_a_bgs.has(file_name):
		_a_bgs[file_name] = []
	_a_bgs[file_name].push_back(player)
	
	_a_BGS.add_child(player)
	
	return player

func replace_bgs(p_stream, p_volume = 1.0, p_pitch = 1.0, p_from = 0.0):
	var path = p_stream.get_path()
	var file_name = path.get_file()
	var player = null
	if _a_bgs.has(file_name):
		player = _a_bgs[file_name][-1]
	
	if player == null:
		player = play_bgs(p_stream, p_volume, p_pitch, p_from)
	else:
		player.set_volume_db(linear_to_db(p_volume))
		player.set_pitch_scale(p_pitch)
	
	return player

func flatten_bgs(p_except = []):
	for child in _a_BGS.get_children():
		if p_except.has(child):
			continue
		_a_BGS.remove_child(child)
		child.queue_free()

func stop_bgs(p_file_name):
	var players = _a_bgs[p_file_name]
	var player = players[-1]
	_a_BGS.remove_child(player)
	player.queue_free()

func play_sfx(p_stream, p_volume = 1.0, p_pitch = 1.0, p_from = 0.0):
	var player = AudioStreamPlayer.new()
	player.finished.connect(_on_SFX_finished.bind(player))
	player.set_stream(p_stream)
	player.set_volume_db(linear_to_db(p_volume))
	player.set_pitch_scale(p_pitch)
	player.set_bus("SFX")
	player.play.call_deferred(p_from)
	
	_a_SFX.add_child(player)

func reset():
	_a_save_data.clear()
	for parent in get_children():
		for child in parent.get_children():
			parent.remove_child(child)
			child.queue_free()

func _set_last_bgm_stream_paused(p_paused):
	if _a_BGM.get_child_count() > 0:
		var last = _a_BGM.get_child(-1)
		last.set_stream_paused_(p_paused)

func get_save_data(p_location):
	_a_save_data[p_location] = {}
	var data = _a_save_data[p_location]
	data["BGM"] = _get_save_data_bgm()
	data["SFX"] = _get_save_data_sfx()
	data["BGS"] = _get_save_data_bgs()
	
	return _a_save_data

func _get_save_data_bgm():
	var data = []
	for child in _a_BGM.get_children():
		var args = child.get_save_data()
		data.push_back(args)
	
	return data

func _get_save_data_bgs():
	var data = []
	for child in _a_BGS.get_children():
		var args = {}
		var stream = child.get_stream()
		var stream_path = stream.get_path()
		args["Stream_Path"] = stream_path
		args["Volume"] = child.get_volume_db()
		args["Pitch"] = child.get_pitch_scale()
		args["Playback_Pos"] = child.get_playback_position()
		
		data.push_back(args)
	
	return data

func _get_save_data_sfx():
	var data = []
	for child in _a_SFX.get_children():
		var args = {}
		var stream = child.get_stream()
		var stream_path = stream.get_path()
		args["Stream_Path"] = stream_path
		args["Volume"] = child.get_volume_db()
		args["Pitch"] = child.get_pitch_scale()
		args["Playback_Pos"] = child.get_playback_position()
		
		data.push_back(args)
	
	return data

func load_file_data(p_data):
	_a_save_data = p_data

func load_data(p_location):
	if !_a_save_data.has(p_location):
		return
	
	var data = _a_save_data[p_location]
	_load_data_bgm(data["BGM"])
	_load_data_bgs(data["BGS"])
	_load_data_sfx(data["SFX"])

func _load_data_bgm(p_args):
	var top_player = null
	if _a_BGM.get_child_count() > 0 && !p_args.is_empty():
		top_player = _a_BGM.get_child(-1)
	flatten_bgm(top_player)
	
	for i in p_args.size():
		var args = p_args[i]
		var stream_path = args["Stream_Path"]
		var stream = load(stream_path)
		var volume = db_to_linear(args["Volume"])
		var pitch = args["Pitch"]
		var playback_pos = args["Playback_Pos"]
		var playing = args["Playing"]
		
		var player = null
		if i < p_args.size() - 1:
			player = play_bgm(stream, volume, pitch, playback_pos)
		else:
			_set_last_bgm_stream_paused(true)
			player = replace_bgm(stream, volume, pitch, playback_pos)
			
			if player == top_player:
				_a_BGM.move_child(player, -1)
			else:
				if top_player != null:
					_a_BGM.remove_child(top_player)
					top_player.queue_free()
		
		player.set_stream_paused_.call_deferred(!playing)

func _load_data_bgs(p_args):
	var players = []
	for i in p_args.size():
		var args = p_args[i]
		var stream_path = args["Stream_Path"]
		var stream = load(stream_path)
		var volume = db_to_linear(args["Volume"])
		var pitch = args["Pitch"]
		var playback_pos = args["Playback_Pos"]
		
		var player = replace_bgs(stream, volume, pitch, playback_pos)
		players.push_back(player)
	flatten_bgs(players)

func _load_data_sfx(p_args):
	for child in _a_SFX.get_children():
		_a_SFX.remove_child(child)
		child.queue_free()
	
	for args in p_args:
		var stream = load(args["Stream_Path"])
		var volume = db_to_linear(args["Volume"])
		var pitch = args["Pitch"]
		var playback_pos = args["Playback_Pos"]
		play_sfx(stream, volume, pitch, playback_pos)

func _on_BGM_finished(p_player):
	var stream = p_player.get_stream()
	var file_path = stream.get_path()
	var file_name = file_path.get_file()
	stop_bgm(file_name)
	
	bgm_finished.emit(file_name)

func _on_BGM_tree_exited(p_file_name):
	var players = _a_bgm[p_file_name]
	players.pop_back()
	if players.is_empty():
		_a_bgm.erase(p_file_name)
	
	_set_last_bgm_stream_paused(false)

func _on_BGS_finished(p_player):
	var stream = p_player.get_stream()
	var file_path = stream.get_path()
	var file_name = file_path.get_file()
	stop_bgs(file_name)
	
	bgs_finished.emit(file_name)

func _on_BGS_tree_exited(p_file_name):
	var players = _a_bgs[p_file_name]
	players.pop_back()
	if players.is_empty():
		_a_bgs.erase(p_file_name)

func _on_SFX_finished(p_player):
	var stream = p_player.get_stream()
	var file_path = stream.get_path()
	var file_name = file_path.get_file()
	_a_SFX.remove_child(p_player)
	p_player.queue_free()
	
	sfx_finished.emit(file_name)
