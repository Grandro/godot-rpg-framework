extends "res://Scenes/Item_Drag_Menu_Base/Scripts/Item_Drag_Menu_Base.gd"

signal closed()

@onready var _a_Stats = get_node("Margin/VBox/HBox/Margin/HBox/VBox_1/Stats")
@onready var _a_Progress = get_node("Margin/VBox/HBox/Margin/HBox/VBox_1/Progress")
@onready var _a_Equipable = get_node("Margin/VBox/HBox/Margin/HBox/VBox_2/Equipable")
@onready var _a_Portraits = get_node("Margin/VBox/HBox/Margin/HBox/VBox_2/Portraits")

var _a_pm_key = ""

func _ready():
	_a_inventory = get_node("Margin/VBox/HBox/Inventory")
	super()
	
	_a_Equipable.equip_slot_pressed.connect(_on_Slot_pressed)
	_a_Equipable.equip_slot_mouse_entered.connect(_on_Slot_mouse_entered)
	_a_Equipable.equip_slot_mouse_exited.connect(_on_Slot_mouse_exited)
	_a_Portraits.entry_pressed.connect(_on_Portraits_entry_pressed)
	_a_inventory.group_changed.connect(_on_Inventory_group_changed)

func open_(p_pm_key, p_args):
	_a_pm_key = p_pm_key
	
	var curr_lvl = p_args["Progress"]["Lvl"]
	_a_inventory.open()
	_a_Stats.open(p_pm_key, p_args["Stats"])
	_a_Progress.open(p_pm_key, p_args["Progress"])
	_a_Equipable.open.call_deferred(p_pm_key, p_args["Equipables"], curr_lvl)
	_a_Portraits.open(p_pm_key)
	
	_update_item_amounts.call_deferred(p_args["Equipables"])
	
	open()

func _close():
	super()
	closed.emit()

func _update_item_amounts(p_args):
	for group in p_args:
		var item_key = p_args[group]
		if !item_key.is_empty():
			_a_inventory.change_item_amount(item_key, -1)

func _drop_item_slot(p_item_key):
	super(p_item_key)
	
	var group = _a_inventory.get_curr_group()
	var slot_item_key = _a_slot.get_item_key()
	if !slot_item_key.is_empty():
		_a_slot.remove_(_a_pm_key, group, true)
	_a_slot.insert_(p_item_key, _a_pm_key, group, true)

func _drop_item_revert(p_item_key):
	super(p_item_key)
	var group = _a_inventory.get_curr_group()
	match _a_item_drag_type:
		"Slot": _a_item_drag_instance.insert_(p_item_key, _a_pm_key, group, true)

func _can_equip_slot_drop():
	var valid = false
	if _a_slot != null:
		var inventory_group = _a_inventory.get_curr_group()
		var slot_group = _a_slot.get_group()
		valid = inventory_group == slot_group
	
	return valid

func _on_Slot_pressed(p_instance):
	var item_key = p_instance.get_item_key()
	if !item_key.is_empty():
		var group = _a_inventory.get_curr_group()
		p_instance.remove_(_a_pm_key, group, true)
		_drag_item(p_instance, item_key, "Slot")

func _on_Portraits_entry_pressed(p_pm_key, p_args):
	open_(p_pm_key, p_args)

func _on_Inventory_item_pressed(p_instance):
	var item_key = p_instance.get_key()
	_a_inventory.change_item_amount(item_key, -1)
	
	_drag_item(p_instance, item_key, "Inventory")

func _on_Inventory_group_changed(p_group):
	var item_key = _a_Equipable.get_equipped_item_key(p_group)
	if item_key.is_empty():
		_a_inventory.close_info_equipped()
	else:
		_a_inventory.display_info_equipped(item_key)
