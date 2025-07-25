extends Control

@onready var _a_VBox = get_node("VBox")
@onready var _a_Stats = get_node("VBox/Margin/Stats/VBox")
@onready var _a_Anims = get_node("Anims")

var _a_stats = {} # Match key to instance
var _a_folded = true

func _ready():
	_a_VBox.gui_input.connect(_on_VBox_gui_input)
	_a_Anims.animation_finished.connect(_on_anim_finished)
	
	for child in _a_Stats.get_children():
		var key = child.get_key()
		_a_stats[key] = child

func set_stat_value(p_stat, p_value, p_anim):
	var instance = _a_stats[p_stat]
	instance.set_value(p_value, p_anim)

func set_stat_max_value(p_stat, p_max_value):
	var instance = _a_stats[p_stat]
	instance.set_max_value(p_max_value)

func _on_VBox_gui_input(p_event):
	if p_event.is_action_pressed("Mouse_Left"):
		if _a_folded:
			_a_Anims.play("Unfold")
		else:
			_a_Anims.play("Fold")

func _on_anim_finished(p_name):
	match p_name:
		"Fold": _a_folded = true
		"Unfold": _a_folded = false
