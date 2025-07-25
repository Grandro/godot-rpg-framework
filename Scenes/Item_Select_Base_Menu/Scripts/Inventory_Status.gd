extends "res://Scenes/Item_Select_Base_Menu/Scripts/Inventory.gd"

@onready var _a_Info_Equipped = get_node("Grid/HBox/Info_Equipped")

func display_info_equipped(p_key):
	_a_Info_Equipped.display(p_key)

func close_info_equipped():
	_a_Info_Equipped.close()
