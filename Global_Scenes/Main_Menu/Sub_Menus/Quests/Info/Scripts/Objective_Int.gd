extends "res://Global_Scenes/Main_Menu/Sub_Menus/Quests/Info/Scripts/Objective_Base.gd"

@onready var _a_Progress_Curr = get_node("Progress/Curr")
@onready var _a_Progress_Target = get_node("Progress/Target")

func _ready():
	super()
	var data = _a_objective_instance.get_data()
	var target_value = data.get_target_value()
	_a_Progress_Target.set_text(str(target_value))

func _set_progress_curr(p_value):
	_a_Progress_Curr.set_text(str(p_value))
