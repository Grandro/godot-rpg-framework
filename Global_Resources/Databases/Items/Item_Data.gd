extends Resource

const _a_NAME_LOC_ID = "ITEMS_%s_%s_NAME"
const _a_DESC_LOC_ID = "ITEMS_%s_%s_DESC"

@export var _e_key: String = ""
@export_enum("General", "Key", "Equipment") var _e_type: String = "General"
@export_enum("Main", "Head", "Torso", "Legs", "Feet", "Weapon", "Shield") var _e_group: String = "Main"
@export_enum("Consumable", "Static", "Equipable") var _e_category_type: String = "Consumable"
@export var _e_stack: int = -1

func get_name_():
	var type_upper = _e_type.to_upper()
	var key_upper = _e_key.to_upper()
	var name_ = tr(_a_NAME_LOC_ID % [type_upper, key_upper])
	
	return name_

func get_desc():
	var type_upper = _e_type.to_upper()
	var key_upper = _e_key.to_upper()
	var desc = tr(_a_DESC_LOC_ID % [type_upper, key_upper])
	
	return desc

func get_type():
	return _e_type

func get_group():
	return _e_group

func get_category_type():
	return _e_category_type

func get_stack_():
	return _e_stack

func get_texture():
	var item_path = Global.get_item_path()
	var texture = load(item_path % _e_key)
	
	return texture
