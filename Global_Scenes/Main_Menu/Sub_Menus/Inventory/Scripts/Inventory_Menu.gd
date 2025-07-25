extends "res://Scenes/Item_Select_Base_Menu/Scripts/Item_Select_Base_Menu.gd"

signal closed(p_data)

@onready var _a_Heading = get_node("Heading")
@onready var _a_Inventory = get_node("Inventory")

func update_trans():
	_a_Heading.set_text(tr("MAIN_MENU_INVENTORY"))

func open(_p_data):
	_a_Inventory.open()
	
	show()

func close():
	queue_free()
	
	var data = {}
	closed.emit(data)
