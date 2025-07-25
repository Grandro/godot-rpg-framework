extends "res://Global_Scenes/Progress/Objects/Scripts/Object_Base.gd"

@onready var _a_Respawn_CD = get_node("Respawn_CD")

func start_respawn():
	_a_Respawn_CD.start()

func get_respawn_rdy():
	return _a_Respawn_CD.is_stopped()

func get_save_data():
	var data = {}
	data["Respawn_Rdy"] = _a_Respawn_CD.is_stopped()
	data["Respawn_CD"] = _a_Respawn_CD.get_time_left()
	
	return data

func load_file_data(p_data):
	var respawn_rdy = p_data["Respawn_Rdy"]
	if !respawn_rdy:
		_a_Respawn_CD.start(p_data["Respawn_CD"])
