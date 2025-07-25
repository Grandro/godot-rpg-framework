extends VBoxContainer

const _a_CHARACTER_SCENE_PATH = "res://Scenes/Characters/%s/%s.tscn"

@onready var _a_VP = get_node("Panel/Margin/VP")

var _a_character = null # Character instance

func update_character(p_key):
	for child in _a_VP.get_children():
		child.queue_free()
	
	var scene = load(_a_CHARACTER_SCENE_PATH % [p_key, p_key])
	var instance = scene.instantiate()
	_a_VP.add_child(instance)
	_a_character = instance

func get_character():
	return _a_character

func _on_Arrow_pressed(p_rotate_degrees):
	var old_dir = _a_character.comph().call_comp("Movement", "get_dir")
	var new_dir = Global.get_dir_rotated(old_dir, p_rotate_degrees)
	_a_character.comph().call_comp("Movement", "set_dir", [new_dir])
	_a_character.comph().call_comp("Anims", "update_anim")
