extends "res://Scenes/Item_Entry/Scripts/Item_Entry_Loot.gd"

signal anim_finished(p_name)

@onready var _a_Anims = get_node("Anims")

func _ready():
	super()
	_a_Anims.animation_finished.connect(_on_anim_finished)

func play_anim(p_name):
	_a_Anims.play(p_name)

func _on_anim_finished(p_name):
	anim_finished.emit(p_name)
