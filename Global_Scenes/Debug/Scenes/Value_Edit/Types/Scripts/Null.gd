extends PanelContainer

signal value_changed(p_value)

@onready var _a_Value = get_node("Value")

func _ready():
	set_default_value()

func expand(_p_depth):
	pass

func delete():
	queue_free()

func set_default_value():
	_a_Value.set_text("[null]")

func set_value(_p_value):
	pass

func get_value():
	return null

func set_editable(_p_editable):
	pass
