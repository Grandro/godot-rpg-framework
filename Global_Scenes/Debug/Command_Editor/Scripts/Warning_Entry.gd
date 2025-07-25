extends ScrollContainer

@onready var _a_Text = get_node("Text")

func set_text(p_text):
	_a_Text.set_text(p_text)
