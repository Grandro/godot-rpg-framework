extends HBoxContainer

@onready var _a_Select = get_node("Select")
@onready var _a_Select_Chapter = get_node("Select_Chapter")

func _ready():
	_a_Select.pressed.connect(_on_Select_pressed)
	Debug.closing.connect(_on_Debug_closing)

func _on_Select_pressed():
	_a_Select_Chapter.open()

func _on_Debug_closing():
	_a_Select_Chapter.close()
