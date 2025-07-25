extends "res://Scenes/Item_Select_Base_Menu/Scripts/Item_Select_Base_Menu.gd"

signal select_pressed(p_key, p_stack, p_texture)

@onready var _a_Item_Select = get_node("Item_Select")

func _ready():
	super()
	_a_Item_Select.select_pressed.connect(_on_Item_Select_select_pressed)

func open(p_key):
	_a_Item_Select.open(p_key)
	show()

func close():
	_a_Item_Select.close()
	super()

func _on_Item_Select_select_pressed(p_key, p_stack, p_texture):
	select_pressed.emit(p_key, p_stack, p_texture)
	close()
