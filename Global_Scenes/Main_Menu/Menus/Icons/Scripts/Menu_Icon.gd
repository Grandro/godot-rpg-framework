extends VBoxContainer

signal pressed()

@export var _e_key: String = ""
@export var _e_menu_scene: PackedScene = null
@export_enum("Menu", "Sub_Menu") var _e_type = "Menu"

const _a_BASE_LOC_ID = "MAIN_MENU_%s"

var _a_Outline_Shader = preload("res://Global_Resources/Materials/2D/Outline.tres")

@onready var _a_Image = get_node("Image")
@onready var _a_Desc = get_node("Desc")

func _ready():
	_a_Image.pressed.connect(_on_Image_pressed)
	_a_Image.focus_entered.connect(_on_Image_focus_entered)
	_a_Image.focus_exited.connect(_on_Image_focus_exited)
	
	_a_Outline_Shader.set_shader_parameter("line_color", Color.WHITE)
	_a_Outline_Shader.set_shader_parameter("line_thickness", 2)
	_a_Desc.set_text(tr(_a_BASE_LOC_ID % _e_key.to_upper()))

func grab_image_focus():
	_a_Image.grab_focus()

func set_image_disabled(p_disabled):
	_a_Image.set_disabled(p_disabled)

func get_key():
	return _e_key

func get_menu_scene():
	return _e_menu_scene

func get_type():
	return _e_type

func _on_Image_pressed():
	pressed.emit()

func _on_Image_focus_entered():
	_a_Image.set_material(_a_Outline_Shader)

func _on_Image_focus_exited():
	_a_Image.set_material(null)
