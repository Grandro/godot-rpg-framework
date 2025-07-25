extends "res://Global_Scenes/Debug/Scenes/Entry_List/Entries/Scripts/Entry.gd"

signal preview_pressed(p_cutscene_data)
signal option_test_selected(p_cutscene_data, p_skip_idxs)
signal selectable_focus_entered()

@onready var _a_Preview = get_node("HBox/VBox/Margin/Margin/HBox/Preview")
@onready var _a_Editor = get_node("HBox/VBox/Options/Editor")

func _ready():
	super()
	_a_Preview.pressed.connect(_on_Preview_pressed)
	_a_Editor.option_test_selected.connect(_on_Editor_option_test_selected)
	_a_Editor.selectable_focus_entered.connect(_on_Editor_selectable_focus_entered)

func update_entries(p_data):
	_a_Editor.update_entries(p_data)

func set_editor_active(p_active):
	_a_Editor.set_active(p_active)

func get_save_data():
	var data = super()
	data["Editor"] = _a_Editor.get_save_data()
	
	return data

func _on_Preview_pressed():
	var cutscene_data = _a_Editor.get_cutscene_data()
	preview_pressed.emit(cutscene_data)

func _on_Editor_option_test_selected(p_instance):
	var cutscene_data = _a_Editor.get_cutscene_data()
	var skip_idxs = _a_Editor.get_skip_idxs(p_instance)
	option_test_selected.emit(cutscene_data, skip_idxs)

func _on_Editor_selectable_focus_entered():
	selectable_focus_entered.emit()
