extends "res://Global_Scenes/Debug/Scenes/Value_Select/Scripts/Value_Select.gd"

signal text_changed(p_text)

@onready var _a_Value = get_node("Value")

func _ready():
	super()
	_a_Value.text_changed.connect(_on_Value_text_changed)

func get_save_data():
	var data = super()
	data["Value"] = _a_Value.get_text()
	
	return data

func load_data(p_data):
	super(p_data)
	_a_Value.set_text(p_data["Value"])

func _on_Var_Select_active_toggled(p_toggled):
	_a_Value.set_editable(!p_toggled)

func _on_Value_text_changed(p_text):
	text_changed.emit(p_text)
