extends "res://Global_Scenes/Progress/Objects/Scripts/Object_Base.gd"

var _a_location = ""
var _a_dest = ""

func _ready():
	var scene_manager_si = Global.get_singleton(self, "Scene_Manager")
	_a_location = scene_manager_si.get_location()

func set_location(p_location):
	_a_location = p_location

func get_location():
	return _a_location

func set_dest(p_dest):
	_a_dest = p_dest

func get_dest():
	return _a_dest

func get_save_data():
	var data = super()
	data["Location"] = _a_location
	data["Dest"] = _a_dest
	
	return data

func load_file_data(p_data):
	super(p_data)
	_a_location = p_data["Location"]
	_a_dest = p_data["Dest"]
