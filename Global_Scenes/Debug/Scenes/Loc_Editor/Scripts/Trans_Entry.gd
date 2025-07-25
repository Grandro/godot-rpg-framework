extends VBoxContainer

signal text_changed(p_text)

@onready var _a_Heading = get_node("Heading")
@onready var _a_Text = get_node("Text")

func _ready():
	_a_Text.text_changed.connect(_on_text_changed)

func set_heading(p_text):
	_a_Heading.set_text("[u]%s" % p_text)

func set_text(p_text):
	_a_Text.set_text(p_text)

func set_text_editable(p_editable):
	_a_Text.set_editable(p_editable)

func _on_text_changed():
	var text = _a_Text.get_text()
	text_changed.emit(text)
