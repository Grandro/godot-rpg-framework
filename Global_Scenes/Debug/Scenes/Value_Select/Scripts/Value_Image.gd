extends "res://Global_Scenes/Debug/Scenes/Value_Select/Scripts/Value_Select.gd"

signal file_path_changed(p_file_path)

@onready var _a_Value = get_node("Value")

func _ready():
	super()
	_a_Value.file_path_changed.connect(_on_Value_file_path_changed)

func get_image_texture():
	return _a_Value.get_image_texture()

func get_save_data():
	var data = super()
	data["Value"] = _a_Value.get_file_path()
	
	return data

func load_data(p_data):
	super(p_data)
	_a_Value.set_file_path(p_data["Value"])

func _on_Var_Select_active_toggled(p_toggled):
	_a_Value.set_disabled(p_toggled)

func _on_Value_file_path_changed(p_file_path):
	file_path_changed.emit(p_file_path)
