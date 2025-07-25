extends "res://Global_Scenes/Debug/Fix_Warnings/Entries/Scripts/Fix_Warning_Base.gd"

@onready var _a_New_Value = get_node("VBox/New/Value")

func _ready():
	super()
	_a_New_Value.text_changed.connect(_on_New_Value_text_changed)

func _on_New_Value_text_changed(p_text):
	_a_new_value = p_text
