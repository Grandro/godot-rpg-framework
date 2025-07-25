extends CanvasLayer

const _a_ENTRY_PATH = "res://Global_Scenes/Debug/Fix_Warnings/Entries/Fix_Warning_%s.tscn"

@onready var _a_Window = get_node("Control/Window")
@onready var _a_Entries = get_node("Control/Window/Contents/Margin/VBox/Scroll/Entries")
@onready var _a_OK = get_node("Control/Window/Contents/Margin/VBox/HBox/OK")
@onready var _a_Cancel = get_node("Control/Window/Contents/Margin/VBox/HBox/Cancel")

var _a_instance = null # Entry instance

func _ready():
	_a_Window.hidden.connect(_on_Window_hidden)
	_a_OK.pressed.connect(_on_OK_pressed)
	_a_Cancel.pressed.connect(_on_Cancel_pressed)
	
	_a_Window.set_title(tr("DEBUG_FIX_WARNINGS"))
	
	hide()

func open(p_instance):
	_a_instance = p_instance
	
	var data = p_instance.get_data()
	var warnings = p_instance.get_warnings()
	for args in warnings:
		var type = args.get_type()
		var scene = load(_a_ENTRY_PATH % type)
		var instance = scene.instantiate()
		instance.set_data(data)
		instance.set_warning(args)
		
		_a_Entries.add_child(instance)
	
	_a_Window.show()
	show()

func close():
	for child in _a_Entries.get_children():
		child.queue_free()
	
	hide()

func _on_Window_hidden():
	close()

func _on_OK_pressed():
	for child in _a_Entries.get_children():
		child.apply_changes()
	
	_a_instance.update_display()
	_a_instance.update_warnings()
	
	close()

func _on_Cancel_pressed():
	close()
