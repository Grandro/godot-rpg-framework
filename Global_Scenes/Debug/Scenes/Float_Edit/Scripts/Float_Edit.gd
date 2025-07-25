extends LineEdit

signal value_changed(p_value)

@export var _e_min: float = 0.0
@export var _e_max: float = 100.0
@export var _e_value: float = 0.0
@export var _e_allow_lesser: bool = false
@export var _e_allow_greater: bool = false

var _a_args = ["0", "0"]

func _ready():
	text_changed.connect(_on_text_changed)
	
	set_value(_e_value)

func _parse_value(p_value):
	match typeof(p_value):
		TYPE_FLOAT: p_value = str(p_value)
		TYPE_INT: p_value = str(p_value)
	
	var args = p_value.split(".")
	if args.size() == 1:
		args.push_back("0")
	
	return args

func _parsed_to_float(p_args):
	var left = float(p_args[0])
	var right = float(p_args[1])
	
	var value = left
	var div = 1
	if value < 0.0:
		right *= -1
	
	for i in p_args[1].length():
		div *= 10
	value += right / float(div)
	
	return value

func _update_text():
	var value = get_value_as_string()
	var pos = value.length()
	set_text(value)
	set_caret_column(pos)

func set_min(p_value):
	if !_e_allow_lesser:
		var value = get_value()
		if value < p_value:
			set_value(p_value)
	
	_e_min = p_value

func set_max(p_value):
	if !_e_allow_greater:
		var value = get_value()
		if value > p_value:
			set_value(p_value)
	
	_e_max = p_value

func set_allow_lesser(p_allow):
	if !p_allow:
		var value = _parsed_to_float(_a_args)
		if value < _e_min:
			set_value(_e_min)
	
	_e_allow_lesser = p_allow

func set_allow_greater(p_allow):
	if !p_allow:
		var value = _parsed_to_float(_a_args)
		if value > _e_max:
			set_value(_e_max)
	
	_e_allow_greater = p_allow

func set_value(p_value, p_update = true):
	_a_args = _parse_value(p_value)
	if p_update:
		_update_text()
	
	_e_value = get_value()
	value_changed.emit(_e_value)

func get_value():
	return _parsed_to_float(_a_args)

func get_value_as_string():
	var left = _a_args[0]
	var right = _a_args[1]
	var value = "%s.%s" % [left, right]
	
	return value

func _on_text_changed(p_text):
	if p_text.is_empty():
		set_value(0.0, false)
		return
	
	if p_text == "-":
		set_value(0.0, false)
		return
	
	if !p_text.is_valid_float():
		_update_text()
		return
	
	var parsed = _parse_value(p_text)
	var value = _parsed_to_float(parsed)
	if !_e_allow_lesser:
		if value < _e_min:
			set_value(_e_min)
			return
	
	if !_e_allow_greater:
		if value > _e_max:
			set_value(_e_max)
			return
	
	set_value(p_text, false)
