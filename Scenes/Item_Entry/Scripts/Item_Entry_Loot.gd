extends "res://Scenes/Item_Entry/Scripts/Item_Entry_Inventory.gd"

@onready var _a_Name = get_node("VBox/Name")

func set_name_(p_name):
	super(p_name)
	_a_Name.set_text(p_name)
