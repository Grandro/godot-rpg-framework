extends "res://Scenes/Item_Drag_Menu_Base/Scripts/Slot.gd"

@export var _e_group: String = ""

@onready var _a_BG_Icon = get_node("BG_Icon")

func _ready():
	var item_type_icon_path = Global.get_item_type_icon_path()
	var texture = load(item_type_icon_path % ["Equipment", _e_group])
	_a_BG_Icon.set_texture(texture)

func insert_(p_item_key, p_pm_key, p_group, p_update):
	insert(p_item_key)
	_a_BG_Icon.hide()
	
	if p_update:
		var global_si = Global.get_singleton(self, "Global")
		global_si.equip_party_member(p_pm_key, p_group, p_item_key)

func remove_(p_pm_key, p_group, p_update):
	remove()
	_a_BG_Icon.show()
	
	if p_update:
		var global_si = Global.get_singleton(self, "Global")
		global_si.unequip_party_member(p_pm_key, p_group)

func get_group():
	return _e_group
