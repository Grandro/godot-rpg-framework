extends Node3D

@onready var _a_Image = get_node("Image")
@onready var _a_Anims = get_node("Anims")

var _a_command = ""

func play_anim(p_name):
	_a_Anims.play(p_name)

func stop_anim(p_keep_state = false):
	_a_Anims.stop(p_keep_state)

func set_image_texture(p_texture):
	_a_Image.set_texture(p_texture)

func set_command(p_command):
	_a_command = p_command

func get_command():
	return _a_command
