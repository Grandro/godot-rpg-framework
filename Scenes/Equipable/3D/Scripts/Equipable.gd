extends Sprite3D

@onready var _a_Anims = get_node("Anims")

func play_anim(p_name, p_speed, p_backwards):
	_a_Anims.play(p_name, -1, p_speed, p_backwards)

func seek_anim(p_seconds, p_update):
	_a_Anims.seek(p_seconds, p_update)

func stop_anim(p_keep_state):
	_a_Anims.stop(p_keep_state)
