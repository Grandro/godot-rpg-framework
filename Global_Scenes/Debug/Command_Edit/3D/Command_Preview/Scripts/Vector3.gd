extends "res://Global_Scenes/Debug/Command_Edit/Command_Preview_Base/Scripts/Vector2.gd"

signal z_value_changed(p_value)

@onready var _a_Z = get_node("Z")

func _ready():
	super()
	_a_Z.value_changed.connect(_on_Z_value_changed)

func set_z_value(p_value):
	_a_Z.set_value(p_value)

func get_value():
	var x = _a_X.get_value()
	var y = _a_Y.get_value()
	var z = _a_Z.get_value()
	
	return Vector3(x, y, z)

func set_z_max(p_max):
	_a_Z.set_max(p_max)

func _on_Z_value_changed(p_value):
	z_value_changed.emit(p_value)
