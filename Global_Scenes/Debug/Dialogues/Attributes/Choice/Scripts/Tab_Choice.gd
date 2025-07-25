extends "res://Global_Scenes/Debug/Dialogues/Attributes/Tabs/Base/Scripts/Tab_Base.gd"

@onready var _a_Entries = get_node("Margin/HSplit/Left/Entries")
@onready var _a_Name = get_node("Margin/HSplit/Left/Name")

func open(p_data):
	_a_Entries.load_data(p_data["Entries"])
	_a_Name.load_data(p_data["Name"])

func open_init():
	_a_Entries.clear_entries()
	_a_Name.load_data_init()

func set_keys_type(p_keys_type):
	_a_Entries.set_keys_type(p_keys_type)
	_a_Name.set_loc_id_type(p_keys_type)

func get_save_data():
	var data = {}
	data["Entries"] = _a_Entries.get_save_data()
	data["Name"] = _a_Name.get_save_data()
	
	return data
