extends PanelContainer

signal value_changed(p_value)

@onready var _a_Value = get_node("Value")

func _ready():
	_a_Value.toggled.connect(_on_Value_toggled)
	
	set_default_value()

func expand(_p_depth):
	pass

func delete():
	queue_free()

func set_default_value():
	set_value(false)

func set_value(p_value):
	_a_Value.set_pressed(p_value)

func get_value():
	return _a_Value.is_pressed()

func set_editable(p_editable):
	_a_Value.set_disabled(!p_editable)

func _on_Value_toggled(p_toggled):
	value_changed.emit(p_toggled)
