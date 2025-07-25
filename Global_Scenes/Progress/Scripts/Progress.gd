extends CanvasLayer

signal progress_changed()
signal chapter_changed(p_chapter)
signal quest_completed(p_key)

const _a_CHAPTERS = ["Chapter_1", "Chapter_2"]
const _a_QUEST_SCENE_PATH = "res://Global_Scenes/Progress/Quests/%s/%s.tscn"
const _a_OBJECT_SCENE_PATH = "res://Global_Scenes/Progress/Objects/%s/%s.tscn"

@onready var _a_Quests = get_node("Quests")
@onready var _a_Objects = get_node("Objects")
@onready var _a_Pins = get_node("Pins")
@onready var _a_Quest_Info = get_node("Quest_Info")
@onready var _a_Loot_Info = get_node("Loot_Info")

var _a_id = "None" # ID used to identify story progress
var _a_chapter = ""
var _a_quests = {} # Match key to instance
var _a_objects = {} # Match key to instance
var _a_dialogue_choices = {} # Key_Type/Chapter/Location/Key/Part_Idx = Value

func init():
	_init_chapter()
	_init_dialogue_choices()

func reset():
	_a_Pins.reset()

func _init_chapter():
	_a_chapter = _a_CHAPTERS[0]

func _init_dialogue_choices():
	for key_type in ["Map", "Global"]:
		_a_dialogue_choices[key_type] = {}
		for chapter in _a_CHAPTERS:
			_a_dialogue_choices[key_type][chapter] = {}

func change_chapter(p_chapter):
	_a_chapter = p_chapter
	
	progress_changed.emit()
	chapter_changed.emit(p_chapter)

func start_quest(p_key):
	var instance = _instantiate_quest(p_key)
	instance.load_data_init()
	
	_a_Quest_Info.open(p_key, "Start")
	
	progress_changed.emit()

func manual_progress_quest_objective(p_key, p_idx):
	var instance = _a_quests[p_key]
	instance.manual_progress_objective(p_idx)
	
	progress_changed.emit()

func call_quest(p_key, p_method_name, p_args = []):
	if !is_quest_started(p_key):
		return false
	
	var instance = _a_quests[p_key]
	if !instance.has_method(p_method_name):
		push_error("Method ", p_method_name, " not implemented in quest ", p_key)
		return
	var method = Callable(instance, p_method_name)
	return method.callv(p_args)

func progress_call_quest(p_key, p_method_name, p_args = []):
	# Call quest instance method to change progress
	var res = call_quest(p_key, p_method_name, p_args)
	progress_changed.emit()
	
	return res

func call_object(p_key, p_method_name, p_args = []):
	if !_a_objects.has(p_key):
		_instantiate_object(p_key)
	
	var instance = _a_objects[p_key]
	if !instance.has_method(p_method_name):
		push_error("Method ", p_method_name, " not implemented in object ", p_key)
		return
	var method = Callable(instance, p_method_name)
	return method.callv(p_args)

func progress_call_object(p_key, p_method_name, p_args = []):
	# Call object instance method to change progress
	var res = call_object(p_key, p_method_name, p_args)
	progress_changed.emit()
	
	return res

func show_pins():
	_a_Pins.show()

func pin_quest(p_key):
	_a_Pins.pin_quest(p_key)

func unpin_quest(p_key):
	_a_Pins.unpin_quest(p_key)

func open_loot_info(p_loot):
	_a_Loot_Info.open(p_loot)

func _instantiate_quest(p_key):
	var scene = load(_a_QUEST_SCENE_PATH % [p_key, p_key])
	var instance = scene.instantiate()
	instance.completed.connect(_on_Quest_completed.bind(p_key))
	_a_quests[p_key] = instance
	_a_Quests.add_child(instance)
	
	return instance

func _instantiate_object(p_key):
	var scene = load(_a_OBJECT_SCENE_PATH % [p_key, p_key])
	var instance = scene.instantiate()
	_a_objects[p_key] = instance
	_a_Objects.add_child(instance)
	
	return instance

func _clear_quests():
	for child in _a_Quests.get_children():
		_a_Quests.remove_child(child)
		child.queue_free()

func _clear_objects():
	for child in _a_Objects.get_children():
		_a_Objects.remove_child(child)
		child.queue_free()

func is_quest_pinned(p_key):
	return _a_Pins.is_quest_pinned(p_key)

func get_quests():
	return _a_quests

func set_dialogue_choice_value(p_key_type, p_key, p_part_idx, p_value):
	var scene_manager_si = Global.get_singleton(self, "Scene_Manager")
	var location = scene_manager_si.get_location()
	var args = _a_dialogue_choices[p_key_type][_a_chapter]
	if !args.has(location):
		args[location] = {}
	if !args[location].has(p_key):
		args[location][p_key] = {}
	args[location][p_key][p_part_idx] = p_value
	
	progress_changed.emit()

func get_dialogue_choice_value(p_key_type, p_chapter, p_location, p_key, p_part_idx):
	var args = _a_dialogue_choices[p_key_type][p_chapter]
	if !args.has(p_location):
		return null
	if !args[p_location].has(p_key):
		return null
	if !args[p_location][p_key].has(p_part_idx):
		return null
	
	return args[p_location][p_key][p_part_idx]

func set_chapter(p_chapter):
	_a_chapter = p_chapter

func get_chapter():
	return _a_chapter

func get_chapters():
	return _a_CHAPTERS

func set_dialogue_choices(p_dialogue_choices):
	_a_dialogue_choices = p_dialogue_choices

func get_dialogue_choices():
	return _a_dialogue_choices

func is_quest_started(p_key):
	return _a_quests.has(p_key)

func is_quest_active(p_key):
	var active = false
	var started = is_quest_started(p_key)
	if started:
		var quest = _a_quests[p_key]
		active = quest.is_active()
	
	return active

func is_quest_complete(p_key):
	var completed = false
	var started = is_quest_started(p_key)
	if started:
		var quest = _a_quests[p_key]
		completed = !quest.is_active()
	
	return completed

func has_quest_progress(p_key, p_value):
	var has_progress = false
	var started = is_quest_started(p_key)
	if started:
		var quest = _a_quests[p_key]
		has_progress = quest.has_progress(p_value)
	
	return has_progress

func get_save_data():
	var data = {}
	data["Progress"] = {}
	data["Progress"]["ID"] = _a_id
	data["Progress"]["Chapter"] = _a_chapter
	data["Progress"]["Dialogue_Choices"] = _a_dialogue_choices
	data["Progress"]["Quests"] = _get_quests_save_data()
	data["Progress"]["Objects"] = _get_objects_save_data()
	data["Pins"] = _a_Pins.get_save_data()
	
	return data

func load_file_data(p_data):
	_a_id = p_data["Progress"]["ID"]
	_a_chapter = p_data["Progress"]["Chapter"]
	_a_dialogue_choices = p_data["Progress"]["Dialogue_Choices"]
	_load_quests_file_data(p_data["Progress"]["Quests"])
	_load_objects_file_data(p_data["Progress"]["Objects"])
	_a_Pins.load_file_data(p_data["Pins"])

func _get_quests_save_data():
	var data = {}
	for key in _a_quests:
		var instance = _a_quests[key]
		data[key] = instance.get_save_data()
	
	return data

func _get_objects_save_data():
	var data = {}
	for key in _a_objects:
		var instance = _a_objects[key]
		data[key] = instance.get_save_data()
	
	return data

func _load_quests_file_data(p_data):
	_clear_quests()
	for key in p_data:
		var instance = _instantiate_quest(key)
		instance.load_file_data(p_data[key])

func _load_objects_file_data(p_data):
	_clear_objects()
	for key in p_data:
		var instance = _instantiate_object(key)
		instance.load_file_data(p_data[key])

func _on_Quest_completed(p_key):
	quest_completed.emit(p_key)
	progress_changed.emit()
