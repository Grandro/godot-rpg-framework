extends VBoxContainer

@onready var _a_Lvl = get_node("Panel/VBox/Lvl/Value")
@onready var _a_Exp_Text = get_node("Panel/VBox/Exp/Text/HBox/Value")
@onready var _a_Exp_Progress = get_node("Panel/VBox/Exp/Progress")

var _a_pm_args = null
var _a_progress = {} # Progress dic for Party_Member

func open(p_pm_args, p_progress, p_exp):
	_a_pm_args = p_pm_args
	_a_progress = p_progress
	_update_lvl()
	_update_curr_exp()
	_set_new_exp(p_exp)
	
	_tween_exp_progress(p_exp)

func _tween_exp_progress(p_exp):
	var curr_exp = _a_progress["Exp"]
	var curr_lvl = _a_progress["Lvl"]
	var next_lvl_exp = _a_pm_args.get_exp_till_next_lvl(curr_lvl + 1)
	var new_exp = curr_exp + p_exp
	var remaining_exp = max(0, new_exp - next_lvl_exp)
	var progress_value = min(new_exp, next_lvl_exp)
	var tween = create_tween()
	tween.finished.connect(_on_Exp_Progress_Tween_finished.bind(remaining_exp))
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(_a_Exp_Progress, "value", progress_value, 1.0).from_current()
	
	_a_progress["Exp"] = progress_value

func _update_lvl():
	var lvl = _a_progress["Lvl"]
	_a_Lvl.set_text(str(lvl))

func _update_curr_exp():
	var curr_exp = _a_progress["Exp"]
	var curr_lvl = _a_progress["Lvl"]
	var next_lvl_exp = _a_pm_args.get_exp_till_next_lvl(curr_lvl + 1)
	_a_Exp_Progress.set_max(next_lvl_exp)
	_a_Exp_Progress.set_value(curr_exp)

func _set_new_exp(p_new_exp):
	_a_Exp_Text.set_text(str(p_new_exp))

func _on_Exp_Progress_Tween_finished(p_remaining_exp):
	if p_remaining_exp > 0:
		_a_progress["Lvl"] += 1
		_a_progress["Exp"] = 0
		_update_lvl()
		_tween_exp_progress(p_remaining_exp)
