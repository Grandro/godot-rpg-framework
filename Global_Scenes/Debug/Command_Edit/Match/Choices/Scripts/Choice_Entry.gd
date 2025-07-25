extends VBoxContainer

@onready var _a_Heading = get_node("Heading")
@onready var _a_Text = get_node("Text/Value")
@onready var _a_Value = get_node("Value/Value")

func set_heading(p_text):
	_a_Heading.set_text("[u]%s" % p_text)

func set_text(p_text):
	_a_Text.set_text(p_text)

func set_value(p_text):
	_a_Value.set_text(p_text)
