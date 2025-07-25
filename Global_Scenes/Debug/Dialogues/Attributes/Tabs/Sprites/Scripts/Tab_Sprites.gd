extends "res://Global_Scenes/Debug/Dialogues/Attributes/Tabs/Base/Scripts/Tab_Base.gd"

@onready var _a_Left_Heading = get_node("Margin/HSplit/Left/Left/Heading")
@onready var _a_Left_Image = get_node("Margin/HSplit/Left/Left/Image")
@onready var _a_Right_Heading = get_node("Margin/HSplit/Left/Right/Heading")
@onready var _a_Right_Image = get_node("Margin/HSplit/Left/Right/Image")
@onready var _a_Mini_Bust_Heading = get_node("Margin/HSplit/Left/Mini_Bust/Heading")
@onready var _a_Mini_Bust_Image = get_node("Margin/HSplit/Left/Mini_Bust/Image")

func update_trans():
	_a_Left_Heading.set_text(tr("DEBUG_DIALOGUES_ATTRIBUTES_SPRITES_LEFT"))
	_a_Right_Heading.set_text(tr("DEBUG_DIALOGUES_ATTRIBUTES_SPRITES_RIGHT"))
	_a_Mini_Bust_Heading.set_text(tr("DEBUG_DIALOGUES_ATTRIBUTES_MINI_BUST"))

func open(p_data):
	_a_Left_Image.set_file_path(p_data["Left"])
	_a_Right_Image.set_file_path(p_data["Right"])
	_a_Mini_Bust_Image.set_file_path(p_data["Mini_Bust"])

func open_init():
	_a_Left_Image.set_file_path("")
	_a_Right_Image.set_file_path("")
	_a_Mini_Bust_Image.set_file_path("")

func get_save_data():
	var data = {}
	data["Left"] = _a_Left_Image.get_file_path()
	data["Right"] = _a_Right_Image.get_file_path()
	data["Mini_Bust"] = _a_Mini_Bust_Image.get_file_path()
	
	return data
