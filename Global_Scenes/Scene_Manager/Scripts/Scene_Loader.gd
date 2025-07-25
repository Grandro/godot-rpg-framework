extends Node

signal progress_changed(p_progress)
signal scene_loaded(p_scene, p_cb, p_value)

var _a_path = "" # Path to loading scene
var _a_scene_loaded_cb = Callable()
var _a_value = null

func _ready():
	set_process(false)

func _process(_p_delta):
	_get_status()

func load_scene(p_path, p_scene_loaded_cb, p_value = null):
	_a_path = p_path
	_a_scene_loaded_cb = p_scene_loaded_cb
	_a_value = p_value
	
	ResourceLoader.load_threaded_request(p_path, "", false)
	set_process(true)

func _get_status():
	var progress_arr = []
	var status = ResourceLoader.load_threaded_get_status(_a_path, progress_arr)
	match status:
		ResourceLoader.THREAD_LOAD_LOADED:
			set_process(false)
			await get_tree().process_frame
			var loaded_scene = ResourceLoader.load_threaded_get(_a_path)
			if _a_value == null:
				scene_loaded.emit(loaded_scene, _a_scene_loaded_cb)
			else:
				scene_loaded.emit(loaded_scene, _a_scene_loaded_cb, _a_value)
			queue_free()
		
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			var progress = progress_arr[0] * 100.0
			progress_changed.emit(progress)
