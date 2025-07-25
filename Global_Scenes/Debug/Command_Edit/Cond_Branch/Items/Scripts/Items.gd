extends "res://Global_Scenes/Debug/Command_Edit/Scripts/Menu_Base.gd"

@onready var _a_Item = get_node("VBox/Item")
@onready var _a_Amount = get_node("VBox/Amount")

func _ready():
	_a_Item.selected.connect(_on_Item_selected)

func _selected_item_changed():
	var key = _a_Item.get_key()
	if key.is_empty():
		_a_Amount.set_max_value_max(0)
	else:
		var stack = _a_Item.get_stack_()
		_a_Amount.set_max_value_max(stack)

func get_save_data():
	var data = {}
	data["Item"] = _a_Item.get_save_data()
	data["Amount"] = _a_Amount.get_save_data()
	
	return data

func load_data(p_data):
	super(p_data)
	_selected_item_changed()

func _load_data_init():
	_a_Item.load_data_init()
	_a_Amount.load_data_init()

func _load_data(p_data):
	_a_Item.load_data(p_data["Item"])
	_a_Amount.load_data(p_data["Amount"])

func _on_Item_selected():
	_selected_item_changed()
