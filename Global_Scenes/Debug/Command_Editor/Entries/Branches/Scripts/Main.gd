extends "res://Global_Scenes/Debug/Command_Editor/Entries/Branches/Scripts/Base.gd"

signal warning_pressed()

var _a_Mark_Default_Image = preload("res://Global_Scenes/Debug/Command_Editor/Entries/Branches/Sprites/Mark_Default.png")
var _a_Mark_Test_Image = preload("res://Global_Scenes/Debug/Command_Editor/Entries/Branches/Sprites/Mark_Test.png")

@onready var _a_Base_Mark = get_node("Base/HBox/Mark")
@onready var _a_Base_Args = get_node("Base/HBox/Args")
@onready var _a_Warning = get_node("Base/HBox/Warning")
@onready var _a_Args = get_node("Args")

func _ready():
	super()
	_a_Warning.pressed.connect(_on_Warning_pressed)
	
	_a_Warning.hide()

func add_args_child(p_child):
	_a_Args.add_child(p_child)

func set_mark(p_mark):
	match p_mark:
		"Default": _a_Base_Mark.set_texture(_a_Mark_Default_Image)
		"Test": _a_Base_Mark.set_texture(_a_Mark_Test_Image)

func set_base_args_modulate(p_color):
	_a_Base_Args.set_modulate(p_color)

func set_base_args(p_args):
	_a_Base_Args.set_text(p_args)

func get_args_children():
	return _a_Args.get_children()

func set_warning_visible(p_visible):
	_a_Warning.set_visible(p_visible)

func get_warning_global_pos():
	return _a_Warning.get_global_position()

func _on_Warning_pressed():
	warning_pressed.emit()
