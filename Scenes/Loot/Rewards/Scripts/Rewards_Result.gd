extends "res://Scenes/Loot/Rewards/Scripts/Rewards_Loot.gd"

func open(p_loot):
	_instantiate_items(p_loot)
	
	if get_child_count() > 0:
		_fade_in_entry(0)
	else:
		completed.emit()

func _fade_in_entry(p_idx):
	var instance = get_child(p_idx)
	instance.anim_finished.connect(_on_Entry_anim_finished.bind(p_idx))
	instance.play_anim("Fade_In")

func _on_Entry_anim_finished(p_anim_name, p_idx):
	if p_anim_name == "Fade_In":
		if get_child_count() - 1 > p_idx:
			var idx = p_idx + 1
			_fade_in_entry(idx)
		else:
			completed.emit()
