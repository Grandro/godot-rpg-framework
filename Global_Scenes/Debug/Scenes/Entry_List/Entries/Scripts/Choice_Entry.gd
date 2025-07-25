extends "res://Global_Scenes/Debug/Scenes/Entry_List/Entries/Scripts/Entry.gd"

@onready var _a_Loc_ID = get_node("HBox/VBox/Options/Loc_ID")
@onready var _a_Value_Heading = get_node("HBox/VBox/Options/Value/Heading")
@onready var _a_Value = get_node("HBox/VBox/Options/Value/Value_Edit")
@onready var _a_Conditions_Heading = get_node("HBox/VBox/Options/Conditions/Heading")
@onready var _a_Conditions = get_node("HBox/VBox/Options/Conditions/Entries")

func update_trans():
	_a_Value_Heading.set_text(tr("DEBUG_DIALOGUES_ATTRIBUTES_VALUE"))
	_a_Conditions_Heading.set_text(tr("DEBUG_DIALOGUES_ATTRIBUTES_CONDITIONS"))

func set_loc_id_type(p_loc_id_type):
	_a_Loc_ID.set_loc_id_type(p_loc_id_type)

func set_loc_id(p_loc_id):
	_a_Loc_ID.set_loc_id(p_loc_id)

func set_value(p_value):
	_a_Value.set_value(p_value)

func get_value():
	return _a_Value.get_value()

func get_value_type():
	return _a_Value.get_type()

func get_save_data():
	var data = super()
	data["Loc_ID"] = _a_Loc_ID.get_save_data()
	data["Value"] = _a_Value.get_value()
	data["Conditions"] = _a_Conditions.get_save_data()
	
	return data

func load_data(p_data):
	super(p_data)
	_a_Conditions.load_data(p_data["Conditions"])
