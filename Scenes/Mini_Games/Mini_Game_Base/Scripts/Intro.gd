extends MarginContainer

signal proceed_pressed()

@onready var _a_Heading = get_node("Margin/VBox/Heading")
@onready var _a_Proceed_Anims = get_node("Margin/VBox/HBox/Right/Proceed/Anims")
@onready var _a_Anims = get_node("Anims")

var _a_game_preview = null

var _a_proceed_pressed = false

func _ready():
	_a_game_preview = get_node("Margin/VBox/HBox/Left/HBox/VP/VP/Game_Preview")
	
	_a_Anims.animation_finished.connect(_on_anim_finished)
	
	set_process_unhandled_input(false)
	hide()

func _unhandled_input(p_event):
	if _a_proceed_pressed:
		if p_event.is_action_released("OK"):
			_a_Proceed_Anims.play("Scale_Up")
			set_process_unhandled_input(false)
	else:
		if p_event.is_action_pressed("OK"):
			_a_Proceed_Anims.play("Scale_Down")
			_a_Anims.play("Fade_Out")
			_a_proceed_pressed = true

func open():
	_a_proceed_pressed = false
	_a_Anims.play("Fade_In")
	
	_a_game_preview.open()
	show()

func _close():
	_a_game_preview.close()
	
	proceed_pressed.emit()
	hide()

func _on_anim_finished(p_name):
	match p_name:
		"Fade_In":
			set_process_unhandled_input(true)
		"Fade_Out":
			_close()
