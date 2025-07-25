extends CanvasLayer

@onready var _a_Anims = get_node("Anims")

func _ready():
	_a_Anims.animation_finished.connect(_on_Anims_anim_finished)
	
	hide()

func open():
	_a_Anims.play("Fade_In")
	
	show()

func close():
	_a_Anims.play("Fade_Out")

func _on_Anims_anim_finished(p_anim_name):
	match p_anim_name:
		"Fade_Out":
			hide()
