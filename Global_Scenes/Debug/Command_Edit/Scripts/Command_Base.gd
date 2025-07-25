extends Control

signal ok_pressed(p_data)

const _a_TITLE_LOC_ID = "DEBUG_CUTSCENES_COMMANDS_%s"

@onready var _a_Window = get_node("Window")
@onready var _a_OK = null
@onready var _a_Cancel = null

func _ready():
	_a_Window.hidden.connect(_on_Window_hidden)
	_a_OK.pressed.connect(_on_OK_pressed)
	_a_Cancel.pressed.connect(_on_Cancel_pressed)
	
	var command = get_name()
	var loc_id = _a_TITLE_LOC_ID % command.to_upper()
	_a_Window.set_title(tr(loc_id))

func open(_p_instance, p_data, p_res_data):
	if p_data.is_empty():
		_open_init(p_res_data)
	else:
		_open_load(p_data, p_res_data)

func _open_init(_p_res_data):
	pass

func _open_load(_p_data, _p_res_data):
	pass

func close():
	queue_free()

func _get_save_data():
	return {}

func _on_Window_hidden():
	close()

func _on_OK_pressed():
	var data = _get_save_data()
	ok_pressed.emit(data)
	close()

func _on_Cancel_pressed():
	close()
