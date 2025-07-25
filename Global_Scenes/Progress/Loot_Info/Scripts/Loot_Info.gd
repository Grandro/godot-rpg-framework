extends Control

@onready var _a_Rewards = get_node("Info/Margin/VBox/Rewards")
@onready var _a_Coins = get_node("Info/Coins")
@onready var _a_Anims = get_node("Anims")
@onready var _a_Audio_Start = get_node("Audio/Start")

var _a_loot = {} # Match item key to amount

func _ready():
	_a_Rewards.completed.connect(_on_Rewards_completed)
	_a_Anims.animation_finished.connect(_on_Anims_anim_finished)
	
	set_process_input(false)
	hide()

func _input(p_event):
	if p_event.is_action_pressed("Proceed_Dialogue"):
		_a_Anims.play("Fade_Out")

func open(p_loot):
	_a_loot = p_loot
	Global.pause()
	
	_a_Coins.open(p_loot)
	
	_a_Audio_Start.play()
	_a_Anims.play("Fade_In")
	
	show()

func _close():
	set_process_input(false)
	_a_Rewards.close()
	Global.unpause()
	hide()

func _faded_in():
	_a_Rewards.open(_a_loot)

func _on_Rewards_completed():
	_a_Coins.count_up()
	set_process_input(true)

func _on_Anims_anim_finished(p_name):
	match p_name:
		"Fade_In":
			_faded_in()
		"Fade_Out":
			_close()
