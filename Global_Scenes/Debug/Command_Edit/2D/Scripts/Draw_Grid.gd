extends Node2D

var _a_start = Vector2.ZERO
var _a_size = Vector2.ZERO
var _a_step = Vector2.ZERO

func update_grid():
	queue_redraw()

func set_start(p_start):
	_a_start = p_start

func get_start():
	return _a_start

func set_size(p_size):
	_a_size = p_size

func set_step(p_step):
	_a_step = p_step

func _draw():
	var world_width = _a_start.x + _a_size.x * _a_step.x
	var world_height = _a_start.y + _a_size.y * _a_step.y
	for x in _a_size.x + 1:
		var line_x = _a_start.x + x * _a_step.x
		var from = Vector2(line_x, _a_start.y)
		var to = Vector2(line_x, world_height)
		draw_line(from, to, Color.WHITE)
	
	for y in _a_size.y + 1:
		var line_y = _a_start.y + y * _a_step.y
		var from = Vector2(_a_start.x, line_y)
		var to = Vector2(world_width, line_y)
		draw_line(from, to, Color.WHITE)
