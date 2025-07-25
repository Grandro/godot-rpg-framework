extends "res://Global_Scenes/Debug/Keys_Editor/Scripts/Keys_Editor.gd"

@onready var _a_VBox = get_node("VBox")
@onready var _a_Parts = get_node("VBox/HBox/Parts")
@onready var _a_Options_Key_Heading = get_node("VBox/HBox/VBox/Options/Key_Heading")
@onready var _a_Options_Preview = get_node("VBox/HBox/VBox/Options/Preview")
@onready var _a_Options_Save = get_node("VBox/HBox/VBox/Options/Save")
@onready var _a_Options_Back = get_node("VBox/HBox/VBox/Options/Back")

var _a_part = null

func _ready():
	super()
	visibility_changed.connect(_on_visibility_changed)
	_a_Parts.entry_select_pressed.connect(_on_Parts_entry_select_pressed)
	_a_Options_Preview.pressed.connect(_on_Options_Preview_pressed)
	_a_Options_Save.pressed.connect(_on_Options_Save_pressed)
	_a_Options_Back.pressed.connect(_on_Options_Back_pressed)
	
	_a_VBox.hide()

func update_trans():
	super()
	_a_Options_Preview.set_text(tr("PREVIEW"))
	_a_Options_Back.set_text(tr("BACK"))

func _open():
	var key = _a_key_entry.get_key()
	_a_Options_Key_Heading.set_text(key)
	_update_parts()
	
	await get_tree().process_frame
	await get_tree().process_frame
	if _a_Parts.get_entry_count() > 0:
		_focus_first_part()
	
	_a_HBox.hide()
	_a_VBox.show()

func _close():
	_update_parts_data()
	
	_a_VBox.hide()
	_a_HBox.show()

func _update_part_data():
	# Update data of a_part
	pass

func _update_parts_data():
	# Collect the data of all part instances
	_update_part_data()
	
	var data = _a_Parts.get_save_data()
	_a_key_entry.set_data(data)

func _update_parts():
	_clear_parts()
	
	var data = _a_key_entry.get_data()
	_a_Parts.load_data(data)

func _clear_parts():
	_a_Parts.clear_entries()

func _focus_first_part():
	var first = _a_Parts.get_entry(0)
	first.grab_select_focus()
	_selected_part_changed(first)

func _selected_part_changed(p_instance):
	_a_part = p_instance

func _on_Scene_Manager_scene_changed(p_instance, p_loaded_file_data):
	super(p_instance, p_loaded_file_data)
	
	_a_VBox.hide()
	_a_HBox.show()

func _on_visibility_changed():
	if !is_instance_valid(_a_part):
		return
	
	if is_visible():
		_selected_part_changed(_a_part)
	else:
		_update_part_data()

func _on_Parts_entry_select_pressed(p_instance):
	_update_part_data()
	_selected_part_changed(p_instance)

func _on_Options_Preview_pressed():
	_update_parts_data()

func _on_Options_Save_pressed():
	_update_parts_data()
	_save_data()

func _on_Options_Back_pressed():
	_close()
