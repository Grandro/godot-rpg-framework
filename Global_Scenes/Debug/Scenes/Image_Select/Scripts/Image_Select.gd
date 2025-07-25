extends HBoxContainer

signal file_path_changed(p_file_path)

@export_dir var _e_curr_dir: String = "res://Global_Resources/Sprites/Mini_Busts/"
@export var _e_texture_none: Texture2D = preload("res://Global_Resources/Sprites/Icons/Background.png")

@onready var _a_Image = get_node("Image")
@onready var _a_Revert = get_node("Revert")
@onready var _a_Revert_Anims = get_node("Revert/Anims")
@onready var _a_File = get_node("File")

var _a_file_path = "" # Path to selected image

func _ready():
	_a_Image.pressed.connect(_on_Image_pressed)
	_a_Revert.pressed.connect(_on_Revert_pressed)
	_a_File.file_selected.connect(_on_File_file_selected)
	
	_a_Image.set_texture_normal(_e_texture_none)
	_a_File.set_current_dir(_e_curr_dir)

func set_file_path(p_file_path):
	var texture = _e_texture_none
	if !p_file_path.is_empty():
		texture = load(p_file_path)
	_a_Image.set_texture_normal(texture)
	_a_file_path = p_file_path

func get_file_path():
	return _a_file_path

func get_image_texture():
	return _a_Image.get_texture_normal()

func set_disabled(p_disabled):
	_a_Image.set_disabled(p_disabled)
	_a_Revert.set_disabled(p_disabled)

func _on_Image_pressed():
	_a_File.popup_centered(Vector2(960, 540))

func _on_Revert_pressed():
	_a_Image.set_texture_normal(_e_texture_none)
	_a_Revert_Anims.play("Spin")
	_a_file_path = ""

func _on_File_file_selected(p_file_path):
	set_file_path(p_file_path)
	file_path_changed.emit(p_file_path)
