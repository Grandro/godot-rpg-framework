extends MarginContainer

signal selected()
signal pressed()
signal request_key(p_key)
signal duplicate_pressed()

@export var _e_focused_color: Color = Color(0.63, 0.81, 0.80)

@onready var _a_Box_Outer = get_node("Box_Outer")
@onready var _a_Key = get_node("Margin/HBox/VBox/HBox/Key")
@onready var _a_Key_Copy = get_node("Margin/HBox/VBox/HBox/Copy")
@onready var _a_Text = get_node("Margin/HBox/VBox/Text")
@onready var _a_Duplicate = get_node("Margin/HBox/Options/Duplicate")
@onready var _a_Delete = get_node("Margin/HBox/Options/Delete")

var _a_data = {}
var _a_key = ""
var _a_time_created = 0.0

func _ready():
	focus_entered.connect(_on_focus_entered)
	_a_Key_Copy.pressed.connect(_on_Key_Copy_pressed)
	_a_Text.text_submitted.connect(_on_Text_text_submitted)
	_a_Text.focus_entered.connect(_on_focus_entered)
	_a_Duplicate.pressed.connect(_on_Duplicate_pressed)
	_a_Delete.pressed.connect(_on_Delete_pressed)

func _gui_input(p_event):
	if p_event.is_action_pressed("Mouse_Left"):
		pressed.emit()

func select():
	_a_Box_Outer.set_self_modulate(_e_focused_color)

func deselect():
	_a_Box_Outer.set_self_modulate(Color.WHITE)

func set_data(p_data):
	_a_data = p_data

func get_data():
	return _a_data

func set_key(p_key):
	_a_key = p_key
	_a_Key.set_text(p_key)

func get_key():
	return _a_key

func set_time_created(p_time_created):
	_a_time_created = p_time_created

func get_time_created():
	return _a_time_created

func set_text(p_text):
	_a_Text.set_text(p_text)

func _on_focus_entered():
	selected.emit()

func _on_Key_Copy_pressed():
	DisplayServer.clipboard_set(_a_key)

func _on_Text_text_submitted(p_text):
	request_key.emit(p_text)

func _on_Duplicate_pressed():
	duplicate_pressed.emit()

func _on_Delete_pressed():
	var messages = Debug.get_messages()
	messages.show_proceed(tr("CONFIRM_DELETE_KEY"), self)

func MESSAGES_PROCEED(p_response):
	if p_response == "Yes":
		queue_free()
