extends "res://Global_Scenes/Debug/Scenes/Value_Select/Scripts/Value_Options.gd"

const _a_ICON_TEXTURE_PATH = "res://Global_Resources/Sprites/Debug/Classes/%s.png"

@export var _e_needed_comps: Array[String] = ["Reference"]
@export var _e_allowed_classes: Array[String] = ["Node"]

var _a_viewport = null

func _ready():
	super()
	Scene_Manager.scene_changed.connect(_on_Scene_Manager_scene_changed)

func update_options():
	_clear_options()
	
	var instances = Global.get_objects_vp(_a_viewport, _e_needed_comps, _e_allowed_classes)
	var i = 0
	for instance in instances:
		var key = instance.comph().call_comp("Reference", "get_key")
		var icon = _get_object_icon(instance)
		
		_a_options[key] = instance
		_a_option_idxs[key] = i
		_a_Value.add_icon_item(icon, key)
		_a_Value.set_item_metadata(i, key)
		i += 1

func set_viewport(p_viewport):
	_a_viewport = p_viewport

func _get_object_icon(p_instance):
	var script = p_instance.get_script()
	var base_type = script.get_instance_base_type()
	var icon = load(_a_ICON_TEXTURE_PATH % base_type)
	
	return icon

func _on_Scene_Manager_scene_changed(_p_instance, _p_loaded_file_data):
	update_options()
