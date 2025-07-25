extends Control

signal anim_finished(p_name)
signal progress_updated()

@onready var _a_Progress = get_node("Progress")
@onready var _a_Anims = get_node("Anims")

func _ready():
	_a_Anims.animation_finished.connect(_on_anim_finished)

func play_anim(p_name):
	_a_Anims.play(p_name)

func update_progress(p_shield):
	var value = _a_Progress.get_value()
	var tween = create_tween()
	tween.finished.connect(_on_Tween_finished)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(_a_Progress, "value", p_shield, 0.5).from(value)

func set_progress_value(p_value):
	_a_Progress.set_value(p_value)

func get_progress_max():
	return _a_Progress.get_max()

func _on_anim_finished(p_name):
	anim_finished.emit(p_name)

func _on_Tween_finished():
	progress_updated.emit()
