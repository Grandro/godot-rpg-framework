extends "res://Global_Scenes/Debug/Command_Edit/Scripts/Command_Base.gd"

const _a_TYPES = ["For"]
const _a_TYPE_LOC_ID = "DEBUG_CUTSCENES_%s"

@onready var _a_Type = get_node("Window/Contents/Margin/VBox/VBox/Type")
@onready var _a_Menus = get_node("Window/Contents/Margin/VBox/VBox/Menus")

var _a_key = "For"
var _a_menus = {}

func _ready():
	_a_OK = get_node("Window/Contents/Margin/VBox/Options/OK")
	_a_Cancel = get_node("Window/Contents/Margin/VBox/Options/Cancel")
	super()
	
	_a_Type.item_selected.connect(_on_Type_item_selected)
	
	for child in _a_Menus.get_children():
		var key = child.get_key()
		_a_menus[key] = child
	
	_create_type_options()

func open(p_instance, p_data, p_res_data):
	for child in _a_Menus.get_children():
		child.hide()
	
	super(p_instance, p_data, p_res_data)
	
	_a_Window.show()
	show()

func _open_init(p_res_data):
	_open_menu(_a_key, {}, p_res_data)

func _open_load(p_data, p_res_data):
	var key = p_data["Key"]
	var args = p_data["Args"]
	_open_menu(key, args, p_res_data)
	
	_a_key = key

func _create_type_options():
	for i in _a_TYPES.size():
		var key = _a_TYPES[i]
		_a_Type.add_item(tr(_a_TYPE_LOC_ID % key.to_upper()))
		_a_Type.set_item_metadata(i, key)

func _open_menu(p_key, p_args = {}, p_res_data = {}):
	var menu = _a_menus[p_key]
	menu.open(p_args, p_res_data)

func _selected_type_changed():
	var key = _a_Type.get_selected_metadata()
	var prev_menu = _a_menus[_a_key]
	prev_menu.hide()
	_open_menu(key)
	
	_a_key = key

func _get_save_data():
	var data = {}
	var menu = _a_menus[_a_key]
	data["Args"] = menu.get_save_data()
	data["Key"] = _a_key
	
	return data

func _on_Type_item_selected(_p_idx):
	_selected_type_changed()
