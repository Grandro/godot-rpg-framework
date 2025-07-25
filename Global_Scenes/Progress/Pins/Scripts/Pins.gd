extends HBoxContainer

var _a_Quest_Icon = preload("res://Global_Scenes/Progress/Pins/Sprites/Quests_Icon.png")

@onready var _a_Menu = get_node("Menu")
@onready var _a_No_Pins = get_node("Menu/Quests/No_Pins")
@onready var _a_Quest_List = get_node("Menu/Quests/Quest_List")
@onready var _a_Info = get_node("Menu/Quests/Info")
@onready var _a_Arrow = get_node("Arrow")
@onready var _a_Anims = get_node("Anims")

var _a_slid_in = false

func _ready():
	var scene_manager_si = Global.get_singleton(self, "Scene_Manager")
	_a_Quest_List.entry_select_pressed.connect(_on_Quest_List_entry_select_pressed)
	_a_Info.back_pressed.connect(_on_Info_back_pressed)
	_a_Arrow.pressed.connect(_on_Arrow_pressed)
	_a_Anims.animation_finished.connect(_on_anim_finished)
	scene_manager_si.scene_changed.connect(_on_Scene_Manager_scene_changed)
	
	_a_Menu.set_tab_title(0, "")
	_a_Menu.set_tab_icon(0, _a_Quest_Icon)
	
	var entry_scene = load("res://Global_Scenes/Debug/Scenes/Entry_List/Entries/Quest_Entry.tscn")
	_a_Quest_List.set_entry_scene(entry_scene)
	
	_a_Info.hide()
	hide()

func reset():
	_a_slid_in = false
	_a_Quest_List.clear_entries()
	_a_Anims.play("Slid_Out")

func pin_quest(p_key):
	var instance = _a_Quest_List.instantiate_entry_(p_key)
	_a_Quest_List.add_entry(instance)
	
	_a_No_Pins.hide()

func unpin_quest(p_key):
	_a_Quest_List.delete_entry(p_key)
	if _a_Info.is_quest_open(p_key):
		_close_info()
	
	if _a_Quest_List.get_entry_count() == 1:
		_a_No_Pins.show()

func is_quest_pinned(p_key):
	return _a_Quest_List.has_entry(p_key)

func _display_info(p_key):
	_a_Quest_List.hide()
	_a_Info.display(p_key)

func _close_info():
	_a_Info.close()
	_a_Quest_List.show()

func get_save_data():
	var data = {}
	data["Slid_In"] = _a_slid_in
	data["Quest_List"] = _a_Quest_List.get_save_data()
	data["Info"] = _get_info_save_data()
	
	return data

func _get_info_save_data():
	var data = {}
	data["Key"] = _a_Info.get_key()
	
	return data

func load_file_data(p_data):
	_a_slid_in = p_data["Slid_In"]
	if _a_slid_in:
		_a_Anims.play("Slid_In")
	else:
		_a_Anims.play("Slid_Out")
	
	_load_quest_list_file_data(p_data["Quest_List"])
	_load_info_file_data(p_data["Info"])

func _load_quest_list_file_data(p_data):
	_a_No_Pins.set_visible(p_data.is_empty())
	_a_Quest_List.load_data(p_data)

func _load_info_file_data(p_data):
	var key = p_data["Key"]
	if !key.is_empty():
		_display_info(key)
	else:
		_close_info()

func _on_Quest_List_entry_select_pressed(p_instance):
	var key = p_instance.get_key()
	_display_info(key)

func _on_Info_back_pressed():
	_close_info()

func _on_Arrow_pressed():
	if _a_slid_in:
		_a_Anims.play("Slide_Out")
	else:
		_a_Anims.play("Slide_In")
	
	_a_slid_in = !_a_slid_in

func _on_anim_finished(p_name):
	match p_name:
		"Slid_In": _a_Arrow.set_flip_h(true)
		"Slid_Out": _a_Arrow.set_flip_h(false)
		"Slide_In": _a_Arrow.set_flip_h(true)
		"Slide_Out": _a_Arrow.set_flip_h(false)

func _on_Scene_Manager_scene_changed(_p_instance, _p_loaded_file_data):
	var scene_manager_si = Global.get_singleton(self, "Scene_Manager")
	if !scene_manager_si.is_curr_scene_map():
		set_visible(false)
		return
	
	var main_menu_si = Global.get_singleton(self, "Main_Menu")
	var is_unlocked = main_menu_si.is_sub_menu_unlocked("Quests")
	set_visible(is_unlocked)
