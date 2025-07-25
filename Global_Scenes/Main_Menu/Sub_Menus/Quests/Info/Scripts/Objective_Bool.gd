extends "res://Global_Scenes/Main_Menu/Sub_Menus/Quests/Info/Scripts/Objective_Base.gd"

@onready var _a_Progress_Curr = get_node("Progress/Curr")

func _set_progress_curr(p_value):
	_a_Progress_Curr.set_pressed(p_value)
