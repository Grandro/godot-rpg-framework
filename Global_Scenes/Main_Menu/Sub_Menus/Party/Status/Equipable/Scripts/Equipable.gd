extends VBoxContainer

signal equip_slot_pressed(p_instance)
signal equip_slot_mouse_entered(p_instance)
signal equip_slot_mouse_exited()

@onready var _a_Curr_Lvl = get_node("Curr_Lvl/Value")
@onready var _a_Outfit = get_node("HBox/Outfit")
@onready var _a_Character = get_node("HBox/Character")
@onready var _a_Equipment = get_node("HBox/Equipment")
@onready var _a_Arrow_Left = get_node("Arrows/Left")
@onready var _a_Arrow_Right = get_node("Arrows/Right")

var _a_equip_slots = {} # Match group to Equip_Slot instance

func _ready():
	_a_Arrow_Left.pressed.connect(_a_Character._on_Arrow_pressed.bind(90))
	_a_Arrow_Right.pressed.connect(_a_Character._on_Arrow_pressed.bind(270))
	
	for parent in [_a_Outfit, _a_Equipment]:
		var children = parent.get_children()
		for i in children.size():
			var child = children[i]
			var group = child.get_group()
			if parent == _a_Outfit:
				child.inserted.connect(_on_Equip_Slot_inserted.bind(group))
				child.removed.connect(_on_Equip_Slot_removed.bind(group))
			child.gui_input.connect(_on_Equip_Slot_gui_input.bind(child))
			child.mouse_entered.connect(_on_Equip_Slot_mouse_entered.bind(child))
			child.mouse_exited.connect(_on_Equip_Slot_mouse_exited)
			
			_a_equip_slots[group] = child

func open(p_key, p_equipment, p_curr_lvl):
	_a_Character.update_character(p_key)
	_update_equipment(p_key, p_equipment)
	_a_Curr_Lvl.set_text(str(p_curr_lvl))

func _update_equipment(p_key, p_equipment):
	for group in _a_equip_slots:
		var equip_slot = _a_equip_slots[group]
		var item_key = equip_slot.get_item_key()
		if !item_key.is_empty():
			equip_slot.remove_(p_key, group, false)
	
	for group in p_equipment:
		var equipable_key = p_equipment[group]
		if equipable_key.is_empty():
			continue
		
		var equip_slot = _a_equip_slots[group]
		equip_slot.insert_(equipable_key, p_key, group, false)

func get_equipped_item_key(p_group):
	var equip_slot = _a_equip_slots[p_group]
	var item_key = equip_slot.get_item_key()
	
	return item_key

func _on_Equip_Slot_inserted(p_item_key, p_group):
	var character = _a_Character.get_character()
	character.comph().call_comp("Equipment", "equip", [p_group, p_item_key])

func _on_Equip_Slot_removed(p_group):
	var character = _a_Character.get_character()
	character.comph().call_comp("Equipment", "unequip", [p_group])

func _on_Equip_Slot_gui_input(p_event, p_instance):
	if p_event.is_action_pressed("Mouse_Left"):
		equip_slot_pressed.emit(p_instance)

func _on_Equip_Slot_mouse_entered(p_instance):
	equip_slot_mouse_entered.emit(p_instance)

func _on_Equip_Slot_mouse_exited():
	equip_slot_mouse_exited.emit()
