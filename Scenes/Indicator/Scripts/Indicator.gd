extends MarginContainer

@export var _e_keyboard_texture: Texture2D = null
@export var _e_joy_letters_color_texture: Texture2D = null
@export var _e_joy_letters_neutral_texture: Texture2D = null
@export var _e_joy_shapes_color_texture: Texture2D = null

@onready var _a_Input = get_node("Margin/HBox/Input")

func _ready():
	Global.use_joy_changed.connect(_on_Global_use_joy_changed)
	
	_update_input_texture()

func _update_input_texture():
	var use_joy = Global.get_use_joy()
	if use_joy:
		var joy_type = Global.get_joy_type()
		match joy_type:
			"Joy_Letters_Color": _a_Input.set_texture(_e_joy_letters_color_texture)
			"Joy_Letters_Neutral": _a_Input.set_texture(_e_joy_letters_neutral_texture)
			"Joy_Shapes_Color": _a_Input.set_texture(_e_joy_shapes_color_texture)
	else:
		_a_Input.set_texture(_e_keyboard_texture)

func _on_Global_use_joy_changed():
	_update_input_texture()
