extends Node

signal scene_changing()
signal scene_changed(p_instance, p_loaded_file_data)

var _a_Scene_Loader_Scene = preload("res://Global_Scenes/Scene_Manager/Scene_Loader.tscn")

@onready var _a_Scene_Loaders = get_node("Scene_Loaders")
@onready var _a_Loading_Screen = get_node("Loading_Screen")

var _a_dest = [] # [location, destination]
var _a_tele = ""
var _a_path = ""
var _a_scene_ready_cb = Callable()
var _a_load_file_data = false
var _a_curr_scene = null
var _a_curr_scene_instance = null
var _a_progress = 0.0

func _ready():
	# Fix for Scene_Manager in Cutscene preview
	var viewport = get_viewport()
	if viewport != get_tree().get_root():
		await get_tree().process_frame
	_a_curr_scene_instance = viewport.get_child(-1)
	
	_a_Loading_Screen.hide()

func change_scene_dest(p_dest, p_scene_ready_cb = Callable()):
	_a_dest = p_dest
	_a_tele = ""
	_a_path = ""
	_a_scene_ready_cb = p_scene_ready_cb
	_a_load_file_data = false
	
	var location = get_location()
	if location == p_dest[0]:
		_update_teleport()
	else:
		_change_scene("Dest")

func change_scene_tele(p_tele, p_scene_ready_cb = Callable(), p_load_file_data = false):
	_a_dest.clear()
	_a_tele = p_tele
	_a_path = ""
	_a_scene_ready_cb = p_scene_ready_cb
	_a_load_file_data = p_load_file_data
	_change_scene("Tele")

func change_scene_path(p_path, p_scene_ready_cb = Callable()):
	_a_dest.clear()
	_a_tele = ""
	_a_path = p_path
	_a_scene_ready_cb = p_scene_ready_cb
	_a_load_file_data = false
	_change_scene("Path")

func load_scene(p_path, p_scene_loaded_cb, p_show_loading):
	var instance = _a_Scene_Loader_Scene.instantiate()
	instance.scene_loaded.connect(_on_Scene_Loader_scene_loaded)
	if p_show_loading:
		instance.progress_changed.connect(_a_Loading_Screen._on_Scene_Loader_progress_changed)
		instance.progress_changed.connect(_on_Scene_Loader_progress_changed)
		_a_Loading_Screen.show()
	instance.load_scene.call_deferred(p_path, p_scene_loaded_cb)
	
	_a_Scene_Loaders.add_child(instance)

func _CB_Scene_Manager_scene_loaded(p_scene):
	_set_new_scene(p_scene)

func _change_scene(p_type):
	if _a_load_file_data:
		var global_si = Global.get_singleton(self, "Global")
		global_si.cleanup_map()
	else:
		if is_curr_scene_map_encounter():
			var global_si = Global.get_singleton(self, "Global")
			global_si.save_data(false)
	
	_a_curr_scene_instance.tree_exited.connect(_on_Scene_tree_exited.bind(p_type))
	_a_curr_scene_instance.queue_free()
	
	scene_changing.emit()

func _scene_changed():
	if is_curr_scene_map_encounter():
		var global_si = Global.get_singleton(self, "Global")
		global_si.load_data(_a_load_file_data)
		
		if _a_curr_scene_instance is MapBase3D:
			var can_jump = _a_curr_scene_instance.get_can_jump()
			var player = global_si.get_player()
			player.comph().call_subcomp("Movement", "Controller", "set_can_jump", [can_jump])
		
		var map_data = global_si.get_saved_map_data()
		if map_data.is_empty():
			_a_curr_scene_instance.load_data_init()
		else:
			_a_curr_scene_instance.load_data(map_data)
		
		_update_teleport.call_deferred()
	
	scene_changed.emit(_a_curr_scene_instance, _a_load_file_data)
	
	if _a_scene_ready_cb.is_valid():
		_a_scene_ready_cb.call(_a_curr_scene_instance)
	
	# Frame needed for signal 'scene_changed' to be processed
	await get_tree().process_frame
	_a_Loading_Screen.hide()

func _update_teleport():
	if !_a_dest.is_empty():
		var data = Databases.get_teleport_data(_a_dest)
		_update_camera(data)
		_update_player(data)

func _update_camera(p_data):
	var global_si = Global.get_singleton(self, "Global")
	var limit_args = p_data.get_camera_limit()
	var limit_active = p_data.is_camera_limit_active()
	if limit_active:
		for side in 4:
			var limit = limit_args[side]
			global_si.set_camera_limit_side(side, limit)
	else:
		global_si.set_camera_limit_side(SIDE_LEFT, -10000000)
		global_si.set_camera_limit_side(SIDE_TOP, -10000000)
		global_si.set_camera_limit_side(SIDE_RIGHT, 10000000)
		global_si.set_camera_limit_side(SIDE_BOTTOM, 10000000)

func _update_player(p_data):
	var global_si = Global.get_singleton(self, "Global")
	var player = global_si.get_player()
	var pos = p_data.get_pos()
	var dir = p_data.get_dir()
	player.set_position(pos)
	player.comph().call_comp("Movement", "set_dir", [dir])
	player.comph().call_comp("Anims", "update_anim")

func _set_new_scene(p_scene):
	_a_curr_scene = p_scene
	_a_curr_scene_instance = p_scene.instantiate()
	_a_curr_scene_instance.ready.connect(_on_Scene_ready)
	
	get_viewport().add_child(_a_curr_scene_instance)

func get_load_file_data():
	return _a_load_file_data

func get_curr_scene():
	return _a_curr_scene

func set_curr_scene_instance(p_curr_scene_instance):
	_a_curr_scene_instance = p_curr_scene_instance

func get_curr_scene_instance():
	return _a_curr_scene_instance

func get_curr_scene_dim():
	if _a_curr_scene_instance is MapBase2D: return "2D"
	if _a_curr_scene_instance is MapBase3D: return "3D"
	if _a_curr_scene_instance is SVEncounterBase: return "3D"

func get_location():
	if is_curr_scene_map_encounter():
		return _a_curr_scene_instance.get_name()
	else:
		return ""

func is_curr_scene_map():
	if _a_curr_scene_instance is MapBase2D: return true
	if _a_curr_scene_instance is MapBase3D: return true
	
	return false

func is_curr_scene_map_encounter():
	if is_curr_scene_map(): return true
	if _a_curr_scene_instance is SVEncounterBase: return true
	
	return false

func get_save_data():
	var data = {}
	data["Location"] = get_location()
	
	return data

func load_file_data(p_data):
	var location = p_data["Location"]
	change_scene_tele(location, Callable(), true)

func _on_Scene_ready():
	_scene_changed()

func _on_Scene_tree_exited(p_type):
	match p_type:
		"Dest":
			var location = _a_dest[0]
			var data = Databases.get_data_entry("Maps", location)
			var path = data.get_path_()
			load_scene(path, _CB_Scene_Manager_scene_loaded, true)
		"Tele":
			var data = Databases.get_data_entry("Maps", _a_tele)
			var path = data.get_path_()
			load_scene(path, _CB_Scene_Manager_scene_loaded, true)
		"Path":
			load_scene(_a_path, _CB_Scene_Manager_scene_loaded, true)

func _on_Scene_Loader_progress_changed(p_progress):
	_a_progress = p_progress

func _on_Scene_Loader_scene_loaded(p_scene, p_scene_loaded_cb):
	p_scene_loaded_cb.call(p_scene)
