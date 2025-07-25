extends PanelContainer

signal inserted(p_item_key, p_mute)
signal removed()

@onready var _a_Item_Icon = get_node("Item_Icon")

var _a_item_key = ""

func insert(p_item_key, p_mute = false):
	_a_item_key = p_item_key
	
	var item_path = Global.get_item_path()
	var texture = load(item_path % p_item_key)
	_a_Item_Icon.set_texture(texture)
	
	inserted.emit(p_item_key, p_mute)

func remove():
	_a_item_key = ""
	_a_Item_Icon.set_texture(null)
	
	removed.emit()

func get_item_key():
	return _a_item_key

func get_save_data():
	var data = {}
	data["Item_Key"] = _a_item_key
	
	return data

func load_data(p_data):
	var item_key = p_data["Item_Key"]
	if !item_key.is_empty():
		insert(item_key, true)
