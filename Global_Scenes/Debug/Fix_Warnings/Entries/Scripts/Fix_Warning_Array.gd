extends "res://Global_Scenes/Debug/Fix_Warnings/Entries/Scripts/Fix_Warning_Base.gd"

@onready var _a_New_Value = get_node("VBox/New/Value")

func _ready():
	super()
	_a_New_Value.value_changed.connect(_on_New_Value_value_changed)

func _on_New_Value_value_changed(p_value):
	_a_new_value = p_value.duplicate()
