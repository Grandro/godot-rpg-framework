extends MarginContainer

const _a_KEY_LOC_ID = "DEBUG_DATABASES_%s"

@onready var _a_Keys = get_node("HBox/Keys")
@onready var _a_Value = get_node("HBox/Scroll/Value")

func _ready():
	for child in _a_Keys.get_children():
		var key = child.get_key()
		child.pressed.connect(_on_Key_pressed.bind(key))

func update_trans():
	for child in _a_Keys.get_children():
		var key = child.get_key()
		var loc_id = _a_KEY_LOC_ID % key.to_upper()
		child.set_text(tr(loc_id))

func _on_Key_pressed(p_key):
	var debug_data = Databases.get_data("Debug")
	var data = debug_data[p_key]
	_a_Value.set_value(data.duplicate(true))
