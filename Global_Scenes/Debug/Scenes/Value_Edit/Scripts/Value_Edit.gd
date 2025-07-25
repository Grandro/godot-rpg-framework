extends MarginContainer

signal value_changed(p_value)

const _a_TYPE_SCENE_PATH = "res://Global_Scenes/Debug/Scenes/Value_Edit/Types/%s.tscn"

@export_enum("Array", "Bool", "Color", "Dictionary",
			 "Float", "Int", "Null", "String", 
			 "Vector2", "Vector3") var _e_type: String = "Null"
@export_enum("Array", "Bool", "Color", "Dictionary",
			 "Float", "Int", "Null", "String", 
			 "Vector2", "Vector3") var _e_children_type: String = "Null"
@export var _e_editable: bool = true
@export var _e_children_editable: bool = true
@export var _e_removable: bool = false

@onready var _a_Text_Panel = get_node("HBox/Text")
@onready var _a_Text = get_node("HBox/Text/Margin/Scroll/Value")
@onready var _a_Type = get_node("HBox/Type")
@onready var _a_VSep = get_node("HBox/VSep")
@onready var _a_Edit = get_node("HBox/Edit")
@onready var _a_Focus_Outlines = get_node("Focus_Outlines")

var _a_instance = null # Current type instance

func _ready():
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	_a_Edit.type_changed.connect(_on_Edit_type_changed)
	_a_Edit.remove_item_pressed.connect(_on_Edit_remove_item_pressed)
	
	_a_Edit.instantiate_types(_e_editable, _e_removable)
	_instantiate_type(_e_type)
	
	if !_e_editable && !_e_removable:
		_a_VSep.hide()
		_a_Edit.hide()
	
	_a_Text_Panel.hide()
	_a_Focus_Outlines.hide()

func expand(p_depth):
	_a_instance.expand(p_depth)

func delete():
	_a_instance.delete()
	queue_free()

func show_text():
	_a_Text_Panel.show()

func _switch_type(p_type):
	if _e_type == p_type:
		return
	
	_e_type = p_type
	_a_instance.queue_free()
	_instantiate_type(p_type)

func _instantiate_type(p_type):
	var scene = load(_a_TYPE_SCENE_PATH % p_type)
	_a_instance = scene.instantiate()
	_a_instance.value_changed.connect(_on_Type_value_changed)
	_a_instance.set_editable.call_deferred(_e_editable)
	
	match p_type:
		"Array":
			_a_instance.set_children_type(_e_children_type)
			_a_instance.set_children_editable(_e_children_editable)
		"Dictionary":
			_a_instance.set_children_type(_e_children_type)
			_a_instance.set_children_editable(_e_children_editable)
	
	_a_Type.add_child(_a_instance)

func set_instance_default_value():
	_a_instance.set_default_value()

func set_text(p_text):
	_a_Text.set_text(p_text)

func get_text():
	return _a_Text.get_text()

func set_value(p_value):
	match typeof(p_value):
		TYPE_DICTIONARY:
			_switch_type("Dictionary")
		TYPE_ARRAY:
			_switch_type("Array")
		TYPE_STRING:
			_switch_type("String")
		TYPE_FLOAT:
			_switch_type("Float")
		TYPE_INT:
			_switch_type("Int")
		TYPE_VECTOR2:
			_switch_type("Vector2")
		TYPE_VECTOR3:
			_switch_type("Vector3")
		TYPE_COLOR:
			_switch_type("Color")
		TYPE_BOOL:
			_switch_type("Bool")
		TYPE_NIL:
			_switch_type("Null")
		_:
			print("Value_Edit doesn't support type of: ",
				  typeof(p_value), " with value ", p_value)
			return
	
	_a_instance.set_value(p_value)

func get_value():
	return _a_instance.get_value()

func set_editable(p_editable):
	_a_VSep.set_visible(p_editable || _e_removable)
	_a_Edit.set_visible(p_editable || _e_removable)
	_a_instance.set_editable(p_editable)
	_e_editable = p_editable

func set_removable(p_removable):
	_e_removable = p_removable

func set_type(p_type):
	_e_type = p_type

func get_type():
	return _e_type

func _on_focus_entered():
	_a_Focus_Outlines.show()

func _on_focus_exited():
	_a_Focus_Outlines.hide()

func _on_Type_value_changed(p_value):
	value_changed.emit(p_value)

func _on_Edit_type_changed(p_type):
	_switch_type(p_type)
	
	var value = _a_instance.get_value()
	value_changed.emit(value)

func _on_Edit_remove_item_pressed():
	queue_free()
