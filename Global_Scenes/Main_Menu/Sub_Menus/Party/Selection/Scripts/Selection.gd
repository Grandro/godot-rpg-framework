extends Control

signal closed()
signal entry_selected(p_key, p_args)

const _a_ENTRY_PATH = "res://Global_Scenes/Main_Menu/Sub_Menus/Party/Selection/%s.tscn"

@onready var _a_Back = get_node("Back")
@onready var _a_HBox = get_node("Margin/VBox/HBox")

func _ready():
	_a_Back.select_pressed.connect(_on_Back_select_pressed)
	
	for child in _a_HBox.get_children():
		child.queue_free()
	
	_instantiate_entries()
	set_process_unhandled_input(false)

func _unhandled_input(p_event):
	if p_event.is_action_pressed("ui_cancel"):
		close()

func open():
	await get_tree().process_frame
	var first = _a_HBox.get_child(0)
	first.grab_select_focus()
	
	set_process_unhandled_input(true)
	show()

func close():
	set_process_unhandled_input(false)
	closed.emit()
	hide()

func _instantiate_entries():
	var global_si = Global.get_singleton(self, "Global")
	var pm_data = global_si.get_party_members_active()
	for key in pm_data:
		var args = pm_data[key]
		var instance = _instantiate_entry(key)
		instance.select_pressed.connect(_on_Entry_select_pressed.bind(key, args))
		
		_a_HBox.add_child(instance)

func _instantiate_entry(p_key):
	var scene = load(_a_ENTRY_PATH % p_key)
	var instance = scene.instantiate()
	
	return instance

func _on_Back_select_pressed():
	close()

func _on_Entry_select_pressed(p_key, p_args):
	entry_selected.emit(p_key, p_args)
	set_process_unhandled_input(false)
	hide()
