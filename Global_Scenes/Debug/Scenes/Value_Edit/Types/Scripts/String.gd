extends PanelContainer

signal value_changed(p_value)

@onready var _a_Value = get_node("Value")

func _ready():
	_a_Value.text_changed.connect(_on_Value_text_changed)
	
	set_default_value()

func expand(_p_depth):
	pass

func delete():
	queue_free()

func set_default_value():
	set_value("")

func set_value(p_value):
	_a_Value.set_text(p_value)

func get_value():
	return _a_Value.get_text()

func set_editable(p_editable):
	_a_Value.set_editable(p_editable)

func _on_Value_text_changed(p_text):
	value_changed.emit(p_text)
