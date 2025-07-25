extends Control

var _a_Warning_Entry_Scene = load("res://Global_Scenes/Debug/Command_Editor/Warning_Entry.tscn")

@onready var _a_Popup = get_node("Popup")
@onready var _a_Margin = get_node("Popup/Margin")
@onready var _a_Entries = get_node("Popup/Margin/VBox/Entries")
@onready var _a_Fix = get_node("Popup/Margin/VBox/Fix")

var _a_instance = null # Entry Instance

func _ready():
	_a_Popup.popup_hide.connect(_on_Popup_hide)
	_a_Fix.pressed.connect(_on_Fix_pressed)
	
	hide()

func open(p_pos, p_instance):
	_a_instance = p_instance
	
	var warnings = p_instance.get_warnings()
	for args in warnings:
		var value_keys = args.get_value_keys()
		var value = args.get_value()
		var text = "%s: %s" % [str(value_keys), str(value)]
		
		var instance = _a_Warning_Entry_Scene.instantiate()
		instance.set_text.call_deferred(text)
		_a_Entries.add_child(instance)
	
	var window_size = get_window().get_size()
	var min_size = _a_Margin.get_minimum_size()
	if p_pos.x + min_size.x > window_size.x:
		p_pos.x = window_size.x - min_size.x
	if p_pos.y + min_size.y > window_size.y:
		p_pos.y = window_size.y - min_size.y
	
	_a_Popup.popup(Rect2(p_pos, Vector2(400, min_size.y + 16)))
	show()

func _on_Popup_hide():
	for child in _a_Entries.get_children():
		child.queue_free()
	hide()

func _on_Fix_pressed():
	var fix_warnings = Debug.get_fix_warnings()
	fix_warnings.open(_a_instance)
	
	_a_Popup.hide()
	hide()
