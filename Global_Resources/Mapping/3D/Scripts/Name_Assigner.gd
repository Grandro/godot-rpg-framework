@tool
extends Node

@export_tool_button("Reassign Names") var _e_button = _on_button_pressed
@export var _e_prefix : String = ""

func _on_button_pressed():
	for i in get_child_count():
		var child = get_child(i)
		var child_name = _e_prefix + str(i + 1)
		child.set_name(child_name)
