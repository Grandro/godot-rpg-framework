extends "res://Global_Scenes/Debug/Fix_Warnings/Entries/Scripts/Fix_Warning_Base.gd"

@onready var _a_New_Value = get_node("VBox/New/Value")
@onready var _a_Select = get_node("Select")
@onready var _a_File = get_node("File")

func _ready():
	super()
	_a_Select.pressed.connect(_on_Select_pressed)
	_a_File.file_selected.connect(_on_File_file_selected)
	
	var dir_path = _a_warning.get_dir_path()
	var filters = _a_warning.get_filters()
	_a_File.set_current_dir(dir_path)
	_a_File.set_filters(filters)

func _on_Select_pressed():
	_a_File.popup_centered(Vector2(480, 660))

func _on_File_file_selected(p_path):
	_a_New_Value.set_text(p_path)
	_a_new_value = p_path
