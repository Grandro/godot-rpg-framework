extends "res://Global_Scenes/Debug/Dialogues/Attributes/Tabs/Base/Scripts/Tab_Base.gd"

const _a_POS_LOC_ID = "POS_%s"
const _a_NAME_TYPES = ["Top", "Bottom"]

@onready var _a_Pos_Type_Heading = get_node("Margin/HSplit/Left/Pos/Type/Heading")
@onready var _a_Pos_Type = get_node("Margin/HSplit/Left/Pos/Type/Options")
@onready var _a_Pos_Custom_VBox = get_node("Margin/HSplit/Left/Pos/Custom")
@onready var _a_Pos_Custom_Heading = get_node("Margin/HSplit/Left/Pos/Custom/Heading")
@onready var _a_Pos_Custom = get_node("Margin/HSplit/Left/Pos/Custom/Value")
@onready var _a_Pos_Name_Type_Heading = get_node("Margin/HSplit/Left/Pos/Name_Type/Heading")
@onready var _a_Pos_Name_Type = get_node("Margin/HSplit/Left/Pos/Name_Type/Options")
@onready var _a_Pos_Small_Preview = get_node("Margin/HSplit/Left/Pos/Small_Preview")
@onready var _a_Name = get_node("Margin/HSplit/Left/Name")
@onready var _a_Show_Arrow_Heading = get_node("Margin/HSplit/Left/Show_Arrow/Heading")
@onready var _a_Show_Arrow = get_node("Margin/HSplit/Left/Show_Arrow/Value")

var _a_pos_type_idxs = {} # Match pos_type key to idx
var _a_pos_name_type_idxs = {} # Match pos_name_type key to idx

func _ready():
	_a_Pos_Type.item_selected.connect(_on_Pos_Type_item_selected)
	_a_Pos_Custom.value_changed.connect(_on_Pos_Custom_value_changed)
	_a_Pos_Name_Type.item_selected.connect(_on_Pos_Name_Type_item_selected)
	_a_Name.selected.connect(_on_Name_selected)
	_a_Show_Arrow.pressed.connect(_on_Show_Arrow_pressed)
	
	_create_pos_type_options()
	_create_pos_name_type_options()

func update_trans():
	_a_Pos_Type_Heading.set_text(tr("DEBUG_DIALOGUES_ATTRIBUTES_TYPE"))
	_a_Pos_Custom_Heading.set_text(tr("CUSTOM"))
	_a_Pos_Name_Type_Heading.set_text(tr("DEBUG_DIALOGUES_ATTRIBUTES_NAME_POS"))
	_a_Show_Arrow_Heading.set_text(tr("DEBUG_DIALOGUES_ATTRIBUTES_SHOW_ARROW"))

func open(p_data):
	var pos_type = p_data["Pos"]["Type"]
	var idx = _a_pos_type_idxs[pos_type]
	_a_Pos_Type.select(idx)
	
	var pos_custom = p_data["Pos"]["Custom"]
	_a_Pos_Custom.set_value(pos_custom)
	
	var pos_name_type = p_data["Pos"]["Name_Type"]
	idx = _a_pos_name_type_idxs[pos_name_type]
	_a_Pos_Name_Type.select(idx)
	
	_a_Name.load_data(p_data["Name"])
	var name_loc_id = p_data["Name"]["Loc_ID"]
	_a_Pos_Small_Preview.set_name_visible(!name_loc_id.is_empty())
	_a_Show_Arrow.set_pressed(p_data["Show_Arrow"])
	
	_selected_type_changed()
	_custom_value_changed()
	_selected_name_type_changed()
	_selected_type_changed()

func open_init():
	_a_Pos_Type.select(0)
	_a_Pos_Custom.set_value(Vector2.ZERO)
	_a_Pos_Name_Type.select(0)
	_a_Name.load_data_init()
	_a_Show_Arrow.set_pressed(false)
	
	_selected_type_changed()
	_custom_value_changed()
	_selected_name_type_changed()
	_selected_type_changed()

func _create_pos_type_options():
	var layouts = Global.get_layouts()
	var layouts_size = layouts.size()
	for i in layouts_size:
		var type = layouts[i]
		var text = tr(_a_POS_LOC_ID % type.to_upper())
		_a_pos_type_idxs[type] = i
		_a_Pos_Type.add_item(text)
		_a_Pos_Type.set_item_metadata(i, type)
	
	_a_pos_type_idxs["Custom"] = layouts_size
	_a_Pos_Type.add_item(tr("CUSTOM"))
	_a_Pos_Type.set_item_metadata(layouts_size, "Custom")

func _create_pos_name_type_options():
	for i in _a_NAME_TYPES.size():
		var name_type = _a_NAME_TYPES[i]
		var text = tr(_a_POS_LOC_ID % name_type.to_upper())
		_a_pos_name_type_idxs[name_type] = i
		_a_Pos_Name_Type.add_item(text)
		_a_Pos_Name_Type.set_item_metadata(i, name_type)

func _selected_type_changed():
	var type = _a_Pos_Type.get_selected_metadata()
	_a_Pos_Custom_VBox.set_visible(type == "Custom")
	_a_Pos_Small_Preview.set_type(type)
	_a_Pos_Small_Preview.update()

func _custom_value_changed():
	var custom = _a_Pos_Custom.get_value() / 10
	_a_Pos_Small_Preview.set_custom(custom)
	_a_Pos_Small_Preview.update()

func _selected_name_type_changed():
	var name_type = _a_Pos_Name_Type.get_selected_metadata()
	_a_Pos_Small_Preview.set_name_type(name_type)
	_a_Pos_Small_Preview.update()

func set_keys_type(p_keys_type):
	_a_Name.set_loc_id_type(p_keys_type)

func get_save_data():
	var data = {}
	data["Pos"] = {}
	data["Pos"]["Type"] = _a_Pos_Type.get_selected_metadata()
	data["Pos"]["Custom"] = _a_Pos_Custom.get_value()
	data["Pos"]["Name_Type"] = _a_Pos_Name_Type.get_selected_metadata()
	data["Name"] = _a_Name.get_save_data()
	data["Show_Arrow"] = _a_Show_Arrow.is_pressed()
	
	return data

func _on_Pos_Type_item_selected(_p_idx):
	_selected_type_changed()

func _on_Pos_Custom_value_changed(_p_value):
	_custom_value_changed()

func _on_Pos_Name_Type_item_selected(_p_idx):
	_selected_name_type_changed()

func _on_Name_selected():
	_a_Pos_Small_Preview.set_name_visible(true)

func _on_Show_Arrow_pressed():
	var show_arrow = _a_Show_Arrow.is_pressed()
	_a_Pos_Small_Preview.set_arrow_visible(show_arrow)
	_a_Pos_Small_Preview.update()
