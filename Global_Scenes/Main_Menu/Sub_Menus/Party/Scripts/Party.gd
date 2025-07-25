extends Control

signal closed(p_data)

@onready var _a_Selection = get_node("Selection")
@onready var _a_Status = get_node("Status")

func _ready():
	_a_Selection.closed.connect(_on_Selection_closed)
	_a_Selection.entry_selected.connect(_on_Selection_entry_selected)
	_a_Status.closed.connect(_on_Status_closed)

func open(_p_data):
	_a_Selection.open()
	
	show()

func _close():
	queue_free()
	
	var data = {}
	closed.emit(data)

func _on_Selection_closed():
	_close()

func _on_Selection_entry_selected(p_pm_key, p_args):
	_a_Status.open_(p_pm_key, p_args)

func _on_Status_closed():
	_a_Selection.open()
