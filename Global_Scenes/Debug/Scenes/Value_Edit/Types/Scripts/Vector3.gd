extends "res://Global_Scenes/Debug/Scenes/Value_Edit/Types/Scripts/Vector2.gd"

@onready var _a_Z_Value = get_node("VBox/Z/HBox/Value")

func _ready():
	super()
	_a_Z_Value.value_changed.connect(_on_value_changed)

func set_default_value():
	set_value(Vector3.ZERO)

func set_value(p_value):
	super(p_value)
	_a_Z_Value.set_value(p_value.z)

func get_value():
	var value = Vector3.ZERO
	value.x = _a_X_Value.get_value()
	value.y = _a_Y_Value.get_value()
	value.z = _a_Z_Value.get_value()
	
	return value

func set_editable(p_editable):
	super(p_editable)
	_a_Z_Value.set_editable(p_editable)
