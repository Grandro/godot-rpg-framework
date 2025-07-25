extends Node3D

@onready var _a_Text = get_node("Pos/Text")
@onready var _a_Anims = get_node("Pos/Text/Anims")

func _ready():
	_a_Anims.animation_finished.connect(_on_anim_finished)
	_a_Anims.play("Fade_Out")

func set_text(p_text):
	_a_Text.set_text(p_text)

func set_modulate(p_color):
	_a_Text.set_modulate(p_color)

func _on_anim_finished(_p_name):
	queue_free()
