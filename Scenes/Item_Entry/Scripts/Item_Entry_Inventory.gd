extends "res://Scenes/Item_Entry/Scripts/Item_Entry_Base.gd"

signal pressed()

@onready var _a_Amount = get_node("VBox/Margin/Amount")
@onready var _a_Select = get_node("Select")

var _a_name = ""
var _a_type = ""
var _a_amount = -1

func _ready():
	_a_Select.pressed.connect(_on_Select_pressed)

func grab_select_focus():
	_a_Select.grab_focus()

func change_amount(p_amount):
	set_amount(_a_amount + p_amount)

func set_name_(p_name):
	_a_name = p_name

func get_name_():
	return _a_name

func set_type(p_type):
	_a_type = p_type

func get_type():
	return _a_type

func set_amount(p_amount):
	_a_amount = p_amount
	_a_Amount.set_text(str(p_amount))
	
	set_visible(p_amount > 0)

func get_amount():
	return _a_amount

func set_amount_visible(p_visible):
	_a_Amount.set_visible(p_visible)

func _on_Select_pressed():
	pressed.emit()
