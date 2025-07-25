extends "res://Global_Scenes/Debug/Dialogues/Attributes/Tabs/Base/Scripts/Tab_Base.gd"

@onready var _a_Text = get_node("Margin/HSplit/Left/Text")

func open(p_data):
	_a_Text.load_data(p_data["Text"])

func open_init():
	_a_Text.load_data_init()

func set_keys_type(p_keys_type):
	_a_Text.set_loc_id_type(p_keys_type)

func get_save_data():
	var data = {}
	data["Text"] = _a_Text.get_save_data()
	
	return data
