extends PanelContainer

signal value_changed(p_value)

@onready var _a_Value = get_node("Value")

func _ready():
	_a_Value.color_changed.connect(_on_color_changed)
	
	set_default_value()

func expand(_p_depth):
	pass

func delete():
	queue_free()

func set_default_value():
	set_value(Color.WHITE)

func set_value(p_value):
	_a_Value.set_pick_color(p_value)

func get_value():
	return _a_Value.get_pick_color()

func set_editable(p_editable):
	_a_Value.set_disabled(!p_editable)

func _on_color_changed(p_color):
	value_changed.emit(p_color)
