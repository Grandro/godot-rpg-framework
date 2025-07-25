extends "res://Global_Scenes/Debug/Scenes/Entry_List/Entries/Scripts/Entry.gd"

@onready var _a_Type = get_node("HBox/VBox/Margin/Margin/HBox/Type")

var _a_point = null # Vector

func set_type_texture(p_texture):
	_a_Type.set_texture(p_texture)

func set_point(p_point):
	_a_point = p_point

func get_point():
	return _a_point

func get_save_data():
	var data = super()
	data["Point"] = _a_point
	
	return data
