extends VBoxContainer

signal selected()

@export var _e_heading_loc_id : String = ""
@export var _e_group : String = ""
@export_enum("Map", "Global") var _e_loc_id_type : String = "Global"

@onready var _a_Heading = get_node("Heading")
@onready var _a_Select = get_node("HBox/Select")
@onready var _a_Revert = get_node("HBox/Revert")

var _a_loc_id = ""

func _ready():
	_a_Select.pressed.connect(_on_Select_pressed)
	_a_Revert.pressed.connect(_on_Revert_pressed)
	
	_a_Select.set_message_translation(false)
	_a_Heading.set_text(tr(_e_heading_loc_id))

func update_trans():
	_a_Heading.set_text(tr(_e_heading_loc_id))

func set_loc_id_type(p_loc_id_type):
	_e_loc_id_type = p_loc_id_type

func set_loc_id(p_loc_id):
	if p_loc_id.is_empty():
		_a_Select.set_text("-")
	else:
		_a_Select.set_text(p_loc_id)
	_a_loc_id = p_loc_id

func get_loc_id():
	return _a_loc_id

func load_data(p_data):
	set_loc_id(p_data["Loc_ID"])

func load_data_init():
	_a_loc_id = ""
	_a_Select.set_text("-")

func get_save_data():
	var data  = {}
	data["Loc_ID"] =_a_loc_id
	
	return data

func _on_Select_pressed():
	var loc_editor = Debug.get_loc_editor()
	loc_editor.loc_id_selected.connect(_on_Loc_Editor_loc_id_selected)
	loc_editor.closed.connect(_on_Loc_Editor_closed)
	loc_editor.set_mode("Select")
	loc_editor.toggle_loc_id_types(_e_loc_id_type)
	loc_editor.open(_e_group, _a_loc_id)

func _on_Revert_pressed():
	set_loc_id("")
	selected.emit("")

func _on_Loc_Editor_loc_id_selected(p_loc_id):
	set_loc_id(p_loc_id)
	selected.emit()

func _on_Loc_Editor_closed():
	var loc_editor = Debug.get_loc_editor()
	loc_editor.loc_id_selected.disconnect(_on_Loc_Editor_loc_id_selected)
	loc_editor.closed.disconnect(_on_Loc_Editor_closed)
