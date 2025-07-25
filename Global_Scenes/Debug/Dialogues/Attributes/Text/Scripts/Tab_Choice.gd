extends "res://Global_Scenes/Debug/Dialogues/Attributes/Tabs/Base/Scripts/Tab_Base.gd"

const _a_POS_LOC_ID = "POS_%s"
const _a_POS_TYPES = ["Left", "Center", "Right"]

@onready var _a_Pos_Heading = get_node("Margin/HSplit/Left/Pos/Heading")
@onready var _a_Pos = get_node("Margin/HSplit/Left/Pos/Options")
@onready var _a_Pos_Small_Preview = get_node("Margin/HSplit/Left/Pos/Small_Preview")
@onready var _a_Entries = get_node("Margin/HSplit/Left/Entries")

var _a_pos_types_idxs = {}

func _ready():
	_a_Pos.item_selected.connect(_on_Pos_item_selected)
	
	_create_pos_types_options()
	
	_a_Pos_Small_Preview.set_name_type("Top")
	_a_Pos_Small_Preview.set_type("Center")
	_a_Pos_Small_Preview.set_choices_box_visible(true)

func update_trans():
	_a_Pos_Heading.set_text(tr("DEBUG_DIALOGUES_ATTRIBUTES_POS"))

func open(p_data):
	var type = p_data["Pos"]["Type"]
	var idx = _a_pos_types_idxs[type]
	_a_Pos.select(idx)
	_a_Pos_Small_Preview.set_choices_box_layout(type)
	
	_a_Entries.load_data(p_data["Entries"])

func open_init():
	_a_Pos.select(0)
	_a_Entries.clear_entries()

func _create_pos_types_options():
	for i in _a_POS_TYPES.size():
		var type = _a_POS_TYPES[i]
		var text = tr(_a_POS_LOC_ID % type.to_upper())
		_a_pos_types_idxs[type] = i
		_a_Pos.add_item(text)
		_a_Pos.set_item_metadata(i, type)

func set_keys_type(p_keys_type):
	_a_Entries.set_keys_type(p_keys_type)

func get_save_data():
	var data = {}
	data["Pos"] = {}
	data["Pos"]["Type"] = _a_Pos.get_selected_metadata()
	data["Entries"] = _a_Entries.get_save_data()
	
	return data

func _on_Pos_item_selected(p_idx):
	var type = _a_Pos.get_item_metadata(p_idx)
	_a_Pos_Small_Preview.set_choices_box_layout(type)
