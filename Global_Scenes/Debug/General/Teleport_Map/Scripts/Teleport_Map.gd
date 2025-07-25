extends HBoxContainer

@onready var _a_Select = get_node("Select")

func _ready():
	_a_Select.pressed.connect(_on_Select_pressed)

func _on_Select_pressed():
	Debug.open_teleport_map()
