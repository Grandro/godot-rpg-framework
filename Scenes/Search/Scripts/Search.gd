extends MarginContainer

signal input_text_changed(p_text)
signal input_text_submitted(p_text)
signal input_focus_entered()

@onready var _a_Input = get_node("Input")

func _ready():
	_a_Input.text_changed.connect(_on_Input_text_changed)
	_a_Input.text_submitted.connect(_on_Input_text_submitted)
	_a_Input.focus_entered.connect(_on_Input_focus_entered)

func set_input_text(p_text):
	_a_Input.set_text(p_text)

func get_input_text():
	return _a_Input.get_text()

func _on_Input_text_changed(p_text):
	input_text_changed.emit(p_text)

func _on_Input_text_submitted(p_text):
	input_text_submitted.emit(p_text)

func _on_Input_focus_entered():
	input_focus_entered.emit()
