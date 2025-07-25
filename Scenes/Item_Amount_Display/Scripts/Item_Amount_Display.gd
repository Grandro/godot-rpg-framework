extends HBoxContainer

@export var _e_key : String = ""

@onready var _a_Text = get_node("Text")

var _a_amount = -1

func _ready():
	var global_si = Global.get_singleton(self, "Global")
	global_si.item_amount_changed.connect(_on_Global_item_amount_changed)
	
	var amount = global_si.get_item_amount(_e_key)
	_set_amount(amount)

func get_amount():
	return _a_amount

func _set_amount(p_amount):
	_a_Text.set_text(str(p_amount))
	_a_amount = p_amount

func _on_Global_item_amount_changed(p_key, p_amount, _p_diff):
	if p_key == _e_key:
		_set_amount(p_amount)
