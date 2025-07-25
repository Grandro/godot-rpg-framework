extends "res://Global_Scenes/Debug/Dialogues/Attributes/Tabs/Base/Scripts/Tab_Base.gd"

signal object_selected(p_key)

@onready var _a_Object = get_node("Margin/HSplit/Left/Object")
@onready var _a_Ensure_Visibility_Heading = get_node("Margin/HSplit/Left/Ensure_Visibility/Heading")
@onready var _a_Ensure_Visibility = get_node("Margin/HSplit/Left/Ensure_Visibility/Value")

func _ready():
	_a_Object.selected.connect(_on_Object_selected)
	Scene_Manager.scene_changed.connect(_on_Scene_Manager_scene_changed)
	
	var root_vp = get_tree().get_root()
	_a_Object.set_viewport(root_vp)

func update_trans():
	_a_Ensure_Visibility_Heading.set_text(tr("DEBUG_DIALOGUES_ATTRIBUTES_ENSURE_VISIBILITY"))

func open(p_data):
	var key = p_data["Object"]
	_a_Object.select(key)
	
	var ensure_visibility = p_data["Ensure_Visibility"]
	_a_Ensure_Visibility.set_pressed(ensure_visibility)

func open_init():
	_a_Ensure_Visibility.set_pressed(true)

func get_save_data():
	var data = {}
	data["Object"] = _a_Object.get_selected_key()
	data["Ensure_Visibility"] = _a_Ensure_Visibility.is_pressed()
	
	return data

func _on_Object_selected():
	var selected_key = _a_Object.get_selected_key()
	object_selected.emit(selected_key)

func _on_Scene_Manager_scene_changed(_p_instance, _p_loaded_file_data):
	_a_Object.update_options()
	_a_Object.add("$Custom", 0)
