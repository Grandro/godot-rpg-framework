extends "res://Global_Scenes/Debug/Scenes/Value_Select/Scripts/Value_Select.gd"

signal pressed()
signal toggled(p_toggled)

@onready var _a_Value = get_node("Value")

func _ready():
	super()
	_a_Value.pressed.connect(_on_Value_pressed)
	_a_Value.toggled.connect(_on_Value_toggled)

func set_pressed(p_pressed):
	_a_Value.set_pressed(p_pressed)

func is_pressed():
	return _a_Value.is_pressed()

func get_save_data():
	var data = super()
	data["Value"] = _a_Value.is_pressed()
	
	return data

func load_data(p_data):
	super(p_data)
	_a_Value.set_pressed(p_data["Value"])

func _on_Var_Select_active_toggled(p_toggled):
	_a_Value.set_disabled(p_toggled)

func _on_Value_pressed():
	pressed.emit()

func _on_Value_toggled(p_toggled):
	toggled.emit(p_toggled)
