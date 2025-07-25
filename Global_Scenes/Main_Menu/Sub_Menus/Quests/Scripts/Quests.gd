extends Control

signal closed(p_data)

@onready var _a_Back = get_node("Back")
@onready var _a_Quest_List = get_node("Margin/HBox/Quest_List")
@onready var _a_Info = get_node("Margin/HBox/Info")

var _a_key = "" # Quest key

func _ready():
	_a_Back.select_pressed.connect(_on_Back_select_pressed)
	_a_Quest_List.entry_select_pressed.connect(_on_Quest_List_entry_select_pressed)
	_a_Info.pin_toggled.connect(_on_Info_pin_toggled)
	
	var entry_scene = load("res://Global_Scenes/Debug/Scenes/Entry_List/Entries/Quest_Entry.tscn")
	_a_Quest_List.set_entry_scene(entry_scene)

func open(p_data):
	if p_data.is_empty():
		_a_Quest_List.instantiate_entries()
	else:
		_a_Quest_List.load_data(p_data["Quest_List"])
	
	if _a_Quest_List.get_child_count() > 0:
		var first = _a_Quest_List.get_entry(0)
		var key = first.get_key()
		_display_quest_entry_info(key)
	
	show()

func close():
	queue_free()
	
	var data = {}
	data["Quest_List"] = _a_Quest_List.get_save_data()
	closed.emit(data)

func _display_quest_entry_info(p_key):
	_a_Info.display(p_key)
	_a_key = p_key

func _on_Back_select_pressed():
	close()

func _on_Quest_List_entry_select_pressed(p_instance):
	var key = p_instance.get_key()
	_display_quest_entry_info(key)

func _on_Info_pin_toggled(p_toggled):
	var progress_si = Global.get_singleton(self, "Progress")
	if p_toggled:
		progress_si.pin_quest(_a_key)
	else:
		progress_si.unpin_quest(_a_key)
