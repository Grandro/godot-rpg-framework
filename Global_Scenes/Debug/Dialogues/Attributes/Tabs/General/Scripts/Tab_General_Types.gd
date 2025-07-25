extends "res://Global_Scenes/Debug/Dialogues/Attributes/Tabs/General/Scripts/Tab_General.gd"

signal type_changed(p_type)

@export var _e_types: Array[String] = []

const _a_TYPE_LOC_ID = "DEBUG_DIALOGUES_ATTRIBUTES_%s"

@onready var _a_Type_Heading = get_node("Margin/HSplit/Left/Type/Heading")
@onready var _a_Type = get_node("Margin/HSplit/Left/Type/Options")

var _a_type_idxs = {} # Match type to idx

func _ready():
	_a_Type.item_selected.connect(_on_Type_item_selected)
	
	_create_types()

func update_trans():
	_a_Type_Heading.set_text(tr("DEBUG_DIALOGUES_ATTRIBUTES_TYPE"))

func open(p_data):
	super(p_data)
	
	var type = p_data["Type"]
	var idx = _a_type_idxs[type]
	_a_Type.select(idx)
	
	type_changed.emit(type)

func open_init():
	super()
	
	var type = _e_types[0]
	var idx = _a_type_idxs[type]
	_a_Type.select(idx)
	
	type_changed.emit(type)

func _create_types():
	for i in _e_types.size():
		var type = _e_types[i]
		var loc_id = _a_TYPE_LOC_ID % type.to_upper()
		_a_type_idxs[type] = i
		_a_Type.add_item(tr(loc_id))
		_a_Type.set_item_metadata(i, type)

func get_save_data():
	var data = super()
	data["Type"] = _a_Type.get_selected_metadata()
	
	return data

func _on_Type_item_selected(p_idx):
	var type = _a_Type.get_item_metadata(p_idx)
	type_changed.emit(type)
