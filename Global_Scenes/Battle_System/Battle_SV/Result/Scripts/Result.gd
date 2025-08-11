extends CanvasLayer

signal closed()

@onready var _a_Rewards = get_node("Control/VBox/Rewards")
@onready var _a_Party_Members = get_node("Control/VBox/Party_Members")
@onready var _a_Coins = get_node("Control/Coins")
@onready var _a_Proceed = get_node("Control/Proceed")
@onready var _a_Anims = get_node("Anims")

var _a_loot = {} # Match item_key to amount

func _ready():
	_a_Rewards.completed.connect(_on_Rewards_completed)
	_a_Proceed.select_pressed.connect(_on_Proceed_select_pressed)
	_a_Anims.animation_finished.connect(_on_anim_finished)
	
	hide()

func open(p_exp, p_loot):
	_a_loot = p_loot
	_a_Party_Members.open(p_exp)
	_a_Coins.open(p_loot)
	_a_Anims.play("Fade_In")
	
	show()

func _close():
	_a_Rewards.close()
	_a_Party_Members.close()
	
	hide()
	closed.emit()

func _on_Rewards_completed():
	_a_Coins.count_up()

func _on_Proceed_select_pressed():
	_close()

func _on_anim_finished(p_anim_name):
	match p_anim_name:
		"Fade_In":
			_a_Rewards.open(_a_loot)
