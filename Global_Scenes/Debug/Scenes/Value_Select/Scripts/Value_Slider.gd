extends "res://Global_Scenes/Debug/Scenes/Value_Select/Scripts/Value_Select.gd"

signal value_changed(p_value)

@export var _e_display_value : bool = false

@onready var _a_Value = get_node("Value")
@onready var _a_Display = get_node("Display")

func _ready():
	super()
	_a_Value.value_changed.connect(_on_Value_value_changed)
	
	_a_Display.set_visible(_e_display_value)

func get_value():
	return _a_Value.get_value()

func get_save_data():
	var data = super()
	data["Value"] = _a_Value.get_value()
	
	return data

func load_data(p_data):
	super(p_data)
	_a_Value.set_value(p_data["Value"])

func _on_Var_Select_active_toggled(p_toggled):
	_a_Value.set_editable(!p_toggled)

func _on_Value_value_changed(p_value):
	_a_Display.set_text(str(p_value))
	value_changed.emit(p_value)
