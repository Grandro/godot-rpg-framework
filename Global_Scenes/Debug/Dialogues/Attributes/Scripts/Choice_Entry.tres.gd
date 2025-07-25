extends VBoxContainer

signal up_pressed()
signal down_pressed()
signal delete_pressed()
signal loc_id_pressed()

@onready var _a_Up = get_node("HBox/Arrows/Up")
@onready var _a_Down = get_node("HBox/Arrows/Down")
@onready var _a_Heading = get_node("HBox/VBox/HBox/Heading")
@onready var _a_Delete = get_node("HBox/VBox/HBox/Delete")
@onready var _a_Loc_ID_Desc = get_node("HBox/VBox/Loc_ID/Desc")
@onready var _a_Loc_ID = get_node("HBox/VBox/Loc_ID/Select")
@onready var _a_Value_Desc = get_node("HBox/VBox/Value/Desc")
@onready var _a_Value = get_node("HBox/VBox/Value/Value_Edit")

var _a_loc_id = ""

func _ready():
	_a_Up.pressed.connect(_on_Up_pressed)
	_a_Down.pressed.connect(_on_Down_pressed)
	_a_Delete.pressed.connect(_on_Delete_pressed)
	_a_Loc_ID.pressed.connect(_on_Loc_ID_pressed)
	
	_a_Loc_ID.set_message_translation(false)

func update_trans():
	_a_Loc_ID_Desc.set_text(tr("DEBUG_DIALOGUES_ATTRIBUTES_LOC_ID"))
	_a_Value_Desc.set_text(tr("DEBUG_DIALOGUES_ATTRIBUTES_VALUE"))

func set_heading(p_text):
	_a_Heading.set_text("[u]%s" % p_text)

func set_loc_id(p_text):
	_a_Loc_ID.set_text(p_text)
	
	_a_loc_id = p_text

func set_value(p_value):
	_a_Value.set_value(p_value)

func get_value():
	return _a_Value.parse_value()

func get_value_type():
	return _a_Value.get_type()

func _on_Up_pressed():
	up_pressed.emit()

func _on_Down_pressed():
	down_pressed.emit()

func _on_Delete_pressed():
	delete_pressed.emit()

func _on_Loc_ID_pressed():
	loc_id_pressed.emit()
