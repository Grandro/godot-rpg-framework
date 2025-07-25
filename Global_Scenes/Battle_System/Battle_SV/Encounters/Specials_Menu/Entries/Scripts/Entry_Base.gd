extends MarginContainer

signal select_pressed()
signal select_focus_entered()

@onready var _a_Select = get_node("Select")
@onready var _a_Name = get_node("Margin/HBox/Name")
@onready var _a_SP_Cost_Text = get_node("Margin/HBox/SP_Cost/Text")

func _ready():
	_a_Select.pressed.connect(_on_Select_pressed)
	_a_Select.focus_entered.connect(_on_Select_focus_entered)

func grab_select_focus():
	_a_Select.grab_focus()

func set_name_text(p_text):
	_a_Name.set_text(p_text)

func set_SP_cost(p_SP_cost):
	_a_SP_Cost_Text.set_text(str(p_SP_cost))

func _on_Select_pressed():
	select_pressed.emit()

func _on_Select_focus_entered():
	select_focus_entered.emit()
