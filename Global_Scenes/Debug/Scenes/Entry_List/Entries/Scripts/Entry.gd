extends MarginContainer

signal up_pressed()
signal down_pressed()
signal select_pressed(p_instance)
signal duplicate_pressed()
signal delete_pressed()
signal name_requested(p_name)
signal name_changed(p_old_name, p_new_name)

var _a_Collapse_Image = preload("res://Global_Resources/Sprites/UI/Collapse.png")
var _a_Expand_Image = preload("res://Global_Resources/Sprites/UI/Expand.png")

@onready var _a_Arrows = get_node("HBox/Arrows")
@onready var _a_Up = get_node("HBox/Arrows/Up")
@onready var _a_Down = get_node("HBox/Arrows/Down")
@onready var _a_Select = get_node("HBox/VBox/Margin/Select")
@onready var _a_Collapse = get_node("HBox/VBox/Margin/Margin/HBox/Collapse")
@onready var _a_Name = get_node("HBox/VBox/Margin/Margin/HBox/Name")
@onready var _a_Duplicate = get_node("HBox/VBox/Margin/Margin/HBox/Options/Duplicate")
@onready var _a_Delete = get_node("HBox/VBox/Margin/Margin/HBox/Options/Delete")
@onready var _a_Options = get_node("HBox/VBox/Options")
@onready var _a_Input = get_node("HBox/VBox/Options/Input")

var _a_can_change_name = true
var _a_visible_by_search = true

func _ready():
	_a_Up.pressed.connect(_on_Up_pressed)
	_a_Down.pressed.connect(_on_Down_pressed)
	_a_Select.pressed.connect(_on_Select_pressed)
	_a_Select.gui_input.connect(_on_Select_gui_input)
	_a_Collapse.pressed.connect(_on_Collapse_pressed)
	_a_Duplicate.pressed.connect(_on_Duplicate_pressed)
	_a_Delete.pressed.connect(_on_Delete_pressed)
	_a_Input.text_submitted.connect(_on_Input_text_submitted)
	
	_a_Name.set_message_translation(false)
	_a_Collapse.set_texture_normal(_a_Expand_Image)
	
	_a_Options.hide()

func grab_select_focus():
	_a_Select.grab_focus()

func _update_visibility():
	set_visible(_a_visible_by_search)

func _handle_copy_action():
	var select_text = _a_Name.get_text()
	DisplayServer.clipboard_set(select_text)

func set_name_(p_name):
	var old_name = _a_Name.get_text()
	_a_Name.set_text(p_name)
	_a_Input.set_text(p_name)
	
	name_changed.emit(old_name, p_name)

func get_name_():
	return _a_Name.get_text()

func set_name_clip_text(p_clip_text):
	_a_Name.set_clip_text(p_clip_text)

func set_select_tooltip_text(p_tooltip_text):
	_a_Select.set_tooltip_text(p_tooltip_text)

func set_arrows_visible(p_arrows_visible):
	_a_Arrows.set_visible(p_arrows_visible)

func set_duplicate_visible(p_duplicate_visible):
	_a_Duplicate.set_visible(p_duplicate_visible)

func set_delete_visible(p_delete_visible):
	_a_Delete.set_visible(p_delete_visible)

func set_input_text(p_input_text):
	_a_Input.set_text(p_input_text)

func set_can_change_name(p_can_change_name):
	_a_can_change_name = p_can_change_name
	_a_Input.set_visible(p_can_change_name)

func set_visible_by_search(p_visible_by_search):
	_a_visible_by_search = p_visible_by_search
	_update_visibility()

func set_collapsed(p_collapsed):
	_a_Options.set_visible(!p_collapsed)
	if p_collapsed:
		_a_Collapse.set_texture_normal(_a_Expand_Image)
	else:
		_a_Collapse.set_texture_normal(_a_Collapse_Image)

func _get_drag_data(_p_position):
	#set_drag_preview(self)
	return self

func get_save_data():
	var data = {}
	data["Name"] = get_name_()
	data["Collapsed"] = !_a_Options.is_visible()
	
	return data

func load_data(p_data):
	if !p_data.has("Collapsed"):
		p_data["Collapsed"] = true
	set_collapsed(p_data["Collapsed"])

func _on_Up_pressed():
	up_pressed.emit()

func _on_Down_pressed():
	down_pressed.emit()

func _on_Select_pressed():
	select_pressed.emit(self)

func _on_Collapse_pressed():
	var options_visible = _a_Options.is_visible()
	set_collapsed(options_visible)

func _on_Select_gui_input(p_event):
	if p_event.is_action_pressed("Copy"):
		_handle_copy_action()

func _on_Duplicate_pressed():
	duplicate_pressed.emit()

func _on_Delete_pressed():
	delete_pressed.emit()

func _on_Input_text_submitted(p_text):
	name_requested.emit(p_text)
