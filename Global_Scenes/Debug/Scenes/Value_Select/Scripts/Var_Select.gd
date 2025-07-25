extends HBoxContainer

signal active_toggled(p_toggled)

@onready var _a_Active = get_node("Active")
@onready var _a_Select = get_node("Select")
@onready var _a_Canvas = get_node("Canvas")
@onready var _a_Panel = get_node("Canvas/Panel")
@onready var _a_Expression = get_node("Canvas/Panel/Margin/Expression")

func _ready():
	_a_Active.toggled.connect(_on_Active_toggled)
	_a_Select.pressed.connect(_on_Select_pressed)
	
	_a_Select.set_disabled(true)
	_a_Expression.update_instances()
	
	_a_Canvas.hide()

func is_active():
	return _a_Active.is_pressed()

func get_save_data():
	var data = {}
	data["Active"] = _a_Active.is_pressed()
	data["Expression"] = _a_Expression.get_save_data()
	
	return data

func load_data(p_data):
	_a_Active.set_pressed(p_data["Active"])
	_a_Expression.load_data(p_data["Expression"])

func load_data_init():
	_a_Active.set_pressed(false)
	_a_Expression.load_data_init()

func _on_Active_toggled(p_toggled):
	_a_Select.set_disabled(!p_toggled)
	if !p_toggled:
		_a_Canvas.hide()
	active_toggled.emit(p_toggled)

func _on_Select_pressed():
	if _a_Canvas.is_visible():
		_a_Canvas.hide()
	else:
		var offset = get_global_position()
		offset.x -= _a_Panel.get_size().x
		_a_Canvas.set_offset(offset)
		
		_a_Canvas.show()
