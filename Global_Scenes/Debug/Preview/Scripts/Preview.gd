extends SubViewportContainer

@export var _e_singletons : Array[String] = ["Global", "FPS_Display", "Scene_Manager",
											 "Audio_Manager", "Dialogue_System",
											 "Cutscene_System", "Progress", "Messages"]

var _a_VP_Scene = preload("res://Global_Scenes/Debug/Preview/VP.tscn")

var _a_preview_scene = null
var _a_vp = null

func open():
	var curr_scene = Scene_Manager.get_curr_scene()
	_a_preview_scene = curr_scene.instantiate()
	_a_vp = _a_VP_Scene.instantiate()
	_make_free_camera_current.call_deferred()
	
	var root = get_tree().get_root()
	for si_name in _e_singletons:
		var child = root.get_node(si_name)
		var scene = load(child.get_scene_file_path())
		var instance = scene.instantiate()
		instance.set_process_mode(PROCESS_MODE_ALWAYS)
		
		_a_vp.add_child(instance)
	
	_a_vp.add_child(_a_preview_scene)
	add_child(_a_vp)
	
	for si_name in _e_singletons:
		var root_child = root.get_node(si_name)
		var vp_child = _a_vp.get_node(si_name)
		_copy_singleton_vars(si_name, root_child, vp_child)
	
	var instances = Global.get_objects_vp(_a_vp, ["Operate"])
	for instance in instances:
		instance.comph().call_comp("Operate", "disable")
	PhysicsServer3D.set_active(true)

func close():
	if _a_vp != null:
		_a_vp.queue_free()
	_a_preview_scene = null
	_a_vp = null

func _make_free_camera_current():
	var global_si = Global.get_singleton(_a_preview_scene, "Global")
	var free_camera = _a_preview_scene.get_free_camera()
	var camera_comp = free_camera.comph().get_comp("Camera")
	global_si.set_curr_camera(camera_comp)

func _copy_singleton_vars(p_si_name, p_org, p_dup):
	match p_si_name:
		"Global":
			p_dup.set_play_time(p_org.get_play_time())
			p_dup.set_camera_limit(p_org.get_camera_limit().duplicate())
			p_dup.set_party_members(p_org.get_party_members().duplicate(true))
			p_dup.set_inventory(p_org.get_inventory().duplicate(true))
		
		"FPS_Display":
			p_dup.set_pos(p_org.get_pos())
		
		"Progress":
			p_dup.set_chapter(p_org.get_chapter())
			p_dup.set_dialogue_choices(p_org.get_dialogue_choices().duplicate(true))

func get_preview_scene():
	return _a_preview_scene

func set_VP_size_2d_override(p_size_2d_override):
	_a_vp.set_size_2d_override(p_size_2d_override)

func get_VP():
	return _a_vp
