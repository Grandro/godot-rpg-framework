extends CanvasLayer

var _a_Main_Scene = preload("res://Global_Scenes/Main_Menu/Menus/Main/Main.tscn")

@onready var _a_Menus = get_node("Menus")

var _a_save_data = {}

var _a_active = false # Is currently active?
var _a_stack = [] # all menu instances

func _ready():
	hide()

func open():
	Global.pause()
	_a_active = true
	open_menu(_a_Main_Scene)
	
	show()

func open_menu(p_scene):
	_disable_last()
	
	var instance = _instantiate_menu(p_scene)
	var data = {}
	for key in instance.get_sub_menus():
		data[key] = _a_save_data["Sub_Menus"][key]["General"]
	instance.set_data(data)
	instance.open.call_deferred()
	
	_a_stack.push_back(instance)
	_a_Menus.add_child(instance)

func open_sub_menu(p_key, p_scene):
	_disable_last()
	
	var data = _a_save_data["Sub_Menus"][p_key]["Menu"]
	var instance = _instantiate_sub_menu(p_key, p_scene)
	instance.open.call_deferred(data)
	
	_a_stack.push_back(instance)
	_a_Menus.add_child(instance)

func _enable_last():
	var last = _a_stack[-1]
	last.set_process_input(true)
	last.open()

func _disable_last():
	if !_a_stack.is_empty():
		var last = _a_stack[-1]
		last.set_process_input(false)
		last.hide()

func close():
	_a_stack.clear()
	for child in _a_Menus.get_children():
		child.tree_exiting.disconnect(_on_Menu_tree_exiting)
		child.queue_free()
	_a_active = false
	await get_tree().process_frame
	hide()
	
	Global.unpause()

func unlock_sub_menu(p_key):
	var sub_menu_data = _a_save_data["Sub_Menus"]
	sub_menu_data[p_key]["General"]["Unlocked"] = true

func _instantiate_menu(p_scene):
	var instance = p_scene.instantiate()
	instance.tree_exiting.connect(_on_Menu_tree_exiting)
	instance.request_menu.connect(_on_Menu_request_menu)
	instance.request_sub_menu.connect(_on_Menu_request_sub_menu)
	
	return instance

func _instantiate_sub_menu(p_key, p_scene):
	var instance = p_scene.instantiate()
	instance.tree_exiting.connect(_on_Menu_tree_exiting)
	instance.closed.connect(_on_Sub_Menu_closed.bind(p_key))
	
	return instance

func is_openable():
	return !_a_active

func is_sub_menu_unlocked(p_key):
	var sub_menu_data = _a_save_data["Sub_Menus"]
	var unlocked = sub_menu_data[p_key]["General"]["Unlocked"]
	
	return unlocked

func reset():
	var main_menu_data = Databases.get_data("Main_Menu")
	_a_save_data.clear()
	_a_save_data["Sub_Menus"] = {}
	
	var sub_menu_data = _a_save_data["Sub_Menus"]
	for key in main_menu_data["Sub_Menus"]:
		var res = main_menu_data["Sub_Menus"][key]
		sub_menu_data[key] = {}
		sub_menu_data[key]["General"] = {}
		sub_menu_data[key]["General"]["Unlocked"] = res.is_unlocked()
		sub_menu_data[key]["Menu"] = {}

func get_save_data():
	return _a_save_data

func load_file_data(p_data):
	_a_save_data = p_data

func _on_Menu_request_menu(p_scene):
	open_menu(p_scene)

func _on_Menu_request_sub_menu(p_key, p_scene):
	open_sub_menu(p_key, p_scene)

func _on_Sub_Menu_closed(p_data, p_key):
	_a_save_data["Sub_Menus"][p_key]["Menu"] = p_data

func _on_Menu_tree_exiting():
	_a_stack.pop_back()
	if _a_stack.is_empty():
		close()
	else:
		_enable_last()
