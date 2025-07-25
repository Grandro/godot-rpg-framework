extends Control

var _a_Item_Entry_Drag_Scene = preload("res://Scenes/Item_Entry/Item_Entry_Base.tscn")

@onready var _a_Back = get_node("Back")

var _a_inventory = null # Inventory instance
var _a_mouse_inventory_group = false # Is mouse hovering over Inventory Group_Entry?
var _a_slot = null # Slot instance mouse hovers over
var _a_item_drag = null # Item_Entry_Drag instance
var _a_item_drag_type = "" # Equip_Slot/Inventory
var _a_item_drag_instance = null # Dragged item / Equip_Slot

func _ready():
	_a_Back.select_pressed.connect(_on_Back_select_pressed)
	_a_inventory.item_pressed.connect(_on_Inventory_item_pressed)
	_a_inventory.group_mouse_entered.connect(_on_Inventory_group_mouse_entered)
	_a_inventory.group_mouse_exited.connect(_on_Inventory_group_mouse_exited)
	
	set_process(false)
	set_process_input(false)
	hide()

func _process(_p_delta):
	var mouse_pos = get_local_mouse_position()
	var item_drag_size = _a_item_drag.get_size() 
	var pos = mouse_pos - item_drag_size / 2
	_a_item_drag.set_position(pos)

func _input(p_event):
	if p_event.is_action_released("Mouse_Left"):
		_drop_item()

func open():
	show()

func _close():
	_a_inventory.close()
	
	set_process_input(false)
	hide()

func _drag_item(p_instance, p_item_key, p_drag_type):
	_a_item_drag_instance = p_instance
	_a_item_drag_type = p_drag_type
	
	var item_path = Global.get_item_path()
	var texture = load(item_path % p_item_key)
	var mouse_pos = get_local_mouse_position()
	_a_item_drag = _a_Item_Entry_Drag_Scene.instantiate()
	_a_item_drag.set_position.call_deferred(mouse_pos)
	_a_item_drag.set_texture.call_deferred(texture)
	_a_item_drag.set_key(p_item_key)
	
	add_child(_a_item_drag)
	
	set_process(true)
	set_process_input(true)

func _drop_item():
	set_process(false)
	set_process_input(false)
	
	var item_key = _a_item_drag.get_key()
	if _can_equip_slot_drop():
		_drop_item_slot(item_key)
	elif _a_mouse_inventory_group:
		_drop_item_inventory(item_key)
	else:
		_drop_item_revert(item_key)
	
	_a_item_drag.queue_free()
	_a_slot = null

func _drop_item_slot(_p_item_key):
	var equipped_item_key = _a_slot.get_item_key()
	if !equipped_item_key.is_empty():
		_a_inventory.change_item_amount(equipped_item_key, 1)

func _drop_item_inventory(p_item_key):
	_a_inventory.change_item_amount(p_item_key, 1)

func _drop_item_revert(p_item_key):
	match _a_item_drag_type:
		"Inventory": _a_inventory.change_item_amount(p_item_key, 1)

func _can_equip_slot_drop():
	return _a_slot != null

func _on_Back_select_pressed():
	_close()

func _on_Inventory_item_pressed(p_instance):
	var item_key = p_instance.get_key()
	_a_inventory.change_item_amount(item_key, -1)
	
	_drag_item(p_instance, item_key, "Inventory")

func _on_Inventory_group_mouse_entered():
	_a_mouse_inventory_group = true

func _on_Inventory_group_mouse_exited():
	_a_mouse_inventory_group = false

func _on_Slot_mouse_entered(p_instance):
	_a_slot = p_instance
 
func _on_Slot_mouse_exited():
	_a_slot = null
