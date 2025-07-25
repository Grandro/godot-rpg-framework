@tool
extends SpinBox

func _ready():
	var line_edit = get_line_edit()
	line_edit.set("custom_constants/minimum_spaces", 0)
