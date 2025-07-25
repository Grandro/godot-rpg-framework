extends VBoxContainer

@onready var _a_Heading = get_node("Heading")

func set_heading_text(p_text):
	_a_Heading.set_text(p_text)
