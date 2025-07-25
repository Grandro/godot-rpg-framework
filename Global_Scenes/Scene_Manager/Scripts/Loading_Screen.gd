extends Control

@onready var _a_Progress = get_node("Center/VBox/Progress")

func _on_Scene_Loader_progress_changed(p_progress):
	_a_Progress.set_value(p_progress * 100)
