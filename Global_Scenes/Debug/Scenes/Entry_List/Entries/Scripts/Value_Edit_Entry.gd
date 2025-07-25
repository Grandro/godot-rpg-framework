extends "res://Global_Scenes/Debug/Scenes/Entry_List/Entries/Scripts/Entry.gd"

@onready var _a_Value = get_node("HBox/VBox/Options/Value")

func set_value(p_value):
	_a_Value.set_value(p_value)

func get_value():
	return _a_Value.get_value()

func set_value_editable(p_editable):
	_a_Value.set_editable(p_editable)

func get_save_data():
	var data = super()
	data["Value"] = get_value()
	
	return data
