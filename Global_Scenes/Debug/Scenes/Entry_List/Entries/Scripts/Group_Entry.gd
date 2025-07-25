extends "res://Global_Scenes/Debug/Scenes/Entry_List/Entries/Scripts/Entry.gd"

@onready var _a_VBox = get_node("HBox/VBox")

var _a_entry_list = null

func _ready():
	_a_VBox.add_child(_a_entry_list)

func set_entry_list(p_entry_list):
	_a_entry_list = p_entry_list
