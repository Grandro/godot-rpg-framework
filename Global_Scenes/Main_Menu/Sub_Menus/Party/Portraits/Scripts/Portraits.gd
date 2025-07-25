extends HBoxContainer

signal entry_pressed(p_key, p_args)

const _a_ENTRY_SCENE_PATH = "res://Global_Scenes/Main_Menu/Sub_Menus/Party/Portraits/Entries/%s.tscn"
const _a_SELECTED_COLOR = Color.WHITE
const _a_NORMAL_COLOR = Color(0.5, 0.5, 0.5, 1.0)

var _a_selected = null

func _ready():
	var global_si = Global.get_singleton(self, "Global")
	var pm_data = global_si.get_party_members_active()
	for key in pm_data:
		var args = pm_data[key]
		var scene = load(_a_ENTRY_SCENE_PATH % key)
		var instance = scene.instantiate()
		instance.pressed.connect(_on_Entry_pressed.bind(instance, args))
		
		add_child(instance)

func open(p_pm_key):
	for child in get_children():
		var key = child.get_key()
		if p_pm_key == key:
			child.set_self_modulate(_a_SELECTED_COLOR)
			_a_selected = child
		else:
			child.set_self_modulate(_a_NORMAL_COLOR)

func _on_Entry_pressed(p_instance, p_args):
	if _a_selected == p_instance:
		return
	
	var key = p_instance.get_key()
	entry_pressed.emit(key, p_args)
