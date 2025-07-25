extends "res://Global_Scenes/Debug/Command_Edit/Scripts/Command_Base.gd"

@onready var _a_Text = get_node("Window/Contents/Margin/VBox/Text")

func _ready():
	_a_OK = get_node("Window/Contents/Margin/VBox/HBox/OK")
	_a_Cancel = get_node("Window/Contents/Margin/VBox/HBox/Cancel")
	super()

func open(p_instance, p_data, p_res_data):
	super(p_instance, p_data, p_res_data)
	
	_a_Window.show()
	show()

func _open_load(p_data, _p_res_data):
	var text = p_data["Text"]
	for i in text.size():
		var wrapped_text = text[i]
		var text_line = ""
		for sub_text in wrapped_text:
			text_line += sub_text
		if i < text.size() - 1:
			text_line += "\n"
		_a_Text.text += text_line

func _get_save_data():
	var data = {}
	data["Text"] = []
	for j in _a_Text.get_line_count():
		var wrapped_text = _a_Text.get_line_wrapped_text(j)
		data["Text"].push_back(wrapped_text)
	
	return data
