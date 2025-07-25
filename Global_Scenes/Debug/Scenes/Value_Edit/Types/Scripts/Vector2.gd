extends VBoxContainer

signal value_changed(p_value)

@onready var _a_Select = get_node("Select")
@onready var _a_VBox = get_node("VBox")
@onready var _a_X_Value = get_node("VBox/X/HBox/Value")
@onready var _a_Y_Value = get_node("VBox/Y/HBox/Value")

func _ready():
	_a_Select.pressed.connect(_on_Select_pressed)
	_a_X_Value.value_changed.connect(_on_value_changed)
	_a_Y_Value.value_changed.connect(_on_value_changed)
	
	set_default_value()

func expand(_p_depth):
	_a_VBox.show()

func delete():
	queue_free()

func set_default_value():
	set_value(Vector2.ZERO)

func set_value(p_value):
	_a_X_Value.set_value(p_value.x)
	_a_Y_Value.set_value(p_value.y)

func get_value():
	var value = Vector2.ZERO
	value.x = _a_X_Value.get_value()
	value.y = _a_Y_Value.get_value()
	
	return value

func set_editable(p_editable):
	_a_X_Value.set_editable(p_editable)
	_a_Y_Value.set_editable(p_editable)

func _on_Select_pressed():
	_a_VBox.visible = !_a_VBox.visible

func _on_value_changed(_p_value):
	var value = get_value()
	value_changed.emit(value)
	
	var str_value = str(value)
	_a_Select.set_text(str_value)
