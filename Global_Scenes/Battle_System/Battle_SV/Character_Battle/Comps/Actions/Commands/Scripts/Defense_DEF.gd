extends "res://Global_Scenes/Battle_System/Battle_SV/Character_Battle/Comps/Actions/Scripts/Action_Base.gd"

func process():
	started.emit()
	pre_event.emit()
	post_event.emit()
	_finished()
