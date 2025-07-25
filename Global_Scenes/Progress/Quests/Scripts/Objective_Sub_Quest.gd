extends "res://Global_Scenes/Progress/Quests/Scripts/Objective_Base.gd"

func _ready():
	if _a_active:
		var progress_si = Global.get_singleton(self, "Progress")
		progress_si.quest_completed.connect(_on_Progress_quest_completed)
	
	super()

func _update_progress():
	# Check if Sub_Quest finished
	var progress_si = Global.get_singleton(self, "Progress")
	var sub_quest_data = _e_data.get_sub_quest()
	var sub_quest_key = sub_quest_data.get_key()
	if progress_si.is_quest_complete(sub_quest_key):
		progressed.emit()
		_completed()

func _completed():
	_a_value = true
	_a_active = false
	completed.emit()

func load_data_init():
	_a_value = false

func _on_Progress_quest_completed(p_key):
	var sub_quest_data = _e_data.get_sub_quest()
	var sub_quest_key = sub_quest_data.get_key()
	if p_key == sub_quest_key:
		var progress_si = Global.get_singleton(self, "Progress")
		progress_si.quest_completed.disconnect(_on_Progress_quest_completed)
		progressed.emit()
		_completed()
