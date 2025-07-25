extends PanelContainer

signal type_changed(p_type)
signal remove_item_pressed()

@export var _e_types: Array[String] = ["Dictionary", "Array", "String", "Float", "Int",
										"Vector2", "Color", "Bool", "Null"]

var _a_Type_Entry_Scene = preload("res://Global_Scenes/Debug/Scenes/Value_Edit/Type_Entry.tscn")
var _a_Type_HSep_Scene = preload("res://Global_Scenes/Debug/Scenes/Value_Edit/Type_HSep.tscn")

@onready var _a_Select = get_node("Select")
@onready var _a_Types = get_node("Select/Types")
@onready var _a_Types_VBox = get_node("Select/Types/VBox")

func _ready():
	_a_Select.pressed.connect(_on_Select_pressed)

func instantiate_types(p_is_editable, p_is_removable):
	if p_is_editable:
		for type in _e_types:
			var instance = _a_Type_Entry_Scene.instantiate()
			instance.pressed.connect(_on_Type_pressed.bind(type))
			instance.set_text(type)
			
			_a_Types_VBox.add_child(instance)
	
	if p_is_removable:
		if p_is_editable:
			var instance = _a_Type_HSep_Scene.instantiate()
			_a_Types_VBox.add_child(instance)
		
		var instance = _a_Type_Entry_Scene.instantiate()
		instance.pressed.connect(_on_Remove_Item_pressed)
		instance.set_text("Remove Item")
		
		_a_Types_VBox.add_child(instance)

func _on_Select_pressed():
	_a_Types.show()
	var pos = get_global_position()
	pos.x -= _a_Types.size.x
	var size_ = _a_Types_VBox.get_size()
	_a_Types.popup(Rect2(pos, size_))
	_a_Types.set_size(size_)

func _on_Type_pressed(p_type):
	_a_Types.hide()
	type_changed.emit(p_type)

func _on_Remove_Item_pressed():
	_a_Types.hide()
	remove_item_pressed.emit()
