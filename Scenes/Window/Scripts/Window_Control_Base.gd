extends VBoxContainer

signal closed()
signal return_pressed() 

enum _a_CORNERS {TOP_LEFT, TOP, TOP_RIGHT, RIGHT, 
				BOTTOM_RIGHT, BOTTOM, BOTTOM_LEFT, LEFT}

@export var _e_window_title: String = ""
@export var _e_resizable: bool = false
@export var _e_closeable: bool = true
@export var _e_show_return: bool = false

@onready var _a_Bar = get_node("Bar")
@onready var _a_Return = get_node("Bar/HBox/Return")
@onready var _a_Heading = get_node("Bar/HBox/Heading")
@onready var _a_Close = get_node("Bar/HBox/Close")

var _a_dragging = false
var _a_can_resize = false
var _a_resizing = false
var _a_resize_corner = -1

func _ready():
	gui_input.connect(_on_gui_input)
	_a_Return.pressed.connect(_on_Return_pressed)
	_a_Bar.gui_input.connect(_on_Bar_gui_input)
	_a_Close.pressed.connect(_on_Close_pressed)
	
	set_title(tr(_e_window_title))
	set_resizable(_e_resizable)
	set_return_visible(_e_show_return)

func _resize_logic(p_event):
	if !_a_resizing:
		var mouse_pos = p_event.get_position()
		_update_resize(mouse_pos)
	
	if Input.is_action_pressed("Mouse_Left"):
		_a_resizing = _a_can_resize
	else:
		_a_resizing = false
	
	if _a_resizing:
		var vp_size = get_viewport_rect().size
		var mouse_pos = get_viewport().get_mouse_position()
		mouse_pos = Vector2(max(mouse_pos.x, 0), max(mouse_pos.y, 0))
		mouse_pos = Vector2(min(mouse_pos.x, vp_size.x), min(mouse_pos.y, vp_size.y))
		var global_pos = get_global_position()
		var dif = mouse_pos - global_pos
		
		var min_size = get_combined_minimum_size()
		var size_ = get_size()
		var pos = get_position()
		
		match _a_resize_corner:
			_a_CORNERS.TOP_LEFT:
				var new_size = size_ - dif
				set_size(new_size)
				
				var new_pos = _get_new_position(pos + dif)
				if new_size.x <= min_size.x:
					size_.x = min_size.x
					new_pos.x = pos.x + (size_.x - min_size.x)
				if new_size.y <= min_size.y:
					size_.y = min_size.y
					new_pos.y = pos.y + (size_.y - min_size.y)
				set_position(new_pos)
			
			_a_CORNERS.TOP:
				var new_size = Vector2(size_.x, size_.y - dif.y)
				set_size(new_size)
				
				var new_pos = _get_new_position(Vector2(pos.x, pos.y + dif.y))
				if new_size.y <= min_size.y:
					size_.y = min_size.y
					new_pos.y = pos.y + (size_.y - min_size.y)
				set_position(new_pos)
			
			_a_CORNERS.TOP_RIGHT:
				var new_size = Vector2(dif.x, size_.y - dif.y)
				set_size(new_size)
				
				var new_pos = _get_new_position(Vector2(pos.x, pos.y + dif.y))
				if new_size.y <= min_size.y:
					size_.y = min_size.y
					new_pos.y = pos.y + (size_.y - min_size.y)
				set_position(new_pos)
			
			_a_CORNERS.RIGHT:
				var new_size = Vector2(dif.x, size_.y)
				set_size(new_size)
				set_position(pos)
			
			_a_CORNERS.BOTTOM_RIGHT:
				set_size(dif)
			
			_a_CORNERS.BOTTOM:
				var new_size = Vector2(size_.x, dif.y)
				set_size(new_size)
				set_position(pos)
			
			_a_CORNERS.BOTTOM_LEFT:
				var new_size = Vector2(size_.x - dif.x, dif.y)
				set_size(new_size)
				
				var new_pos = _get_new_position(Vector2(pos.x + dif.x, pos.y))
				if new_size.x <= min_size.x:
					size_.x = min_size.x
					new_pos.x = pos.x + (size_.x - min_size.x)
				set_position(new_pos)
			
			_a_CORNERS.LEFT:
				var new_size = Vector2(size_.x - dif.x, size_.y)
				set_size(new_size)
				
				var new_pos = _get_new_position(Vector2(pos.x + dif.x, pos.y))
				if new_size.x <= min_size.x:
					size_.x = min_size.x
					new_pos.x = pos.x + (size_.x - min_size.x)
				set_position(new_pos)
	else:
		if !_a_can_resize:
			_a_resize_corner = -1
			set_default_cursor_shape(Control.CURSOR_ARROW)

func _update_resize(p_pos):
	var size_ = get_size()
	var top = 0
	var left = 0
	var right = size_.x
	var bottom = size_.y
	
	_a_can_resize = true
	
	# Top_Left, Bottom_Left, Left
	if p_pos.x - left <= 4:
		if p_pos.y - top <= 4:
			set_default_cursor_shape(Control.CURSOR_FDIAGSIZE)
			_a_resize_corner = _a_CORNERS.TOP_LEFT
		elif bottom - p_pos.y <= 4:
			set_default_cursor_shape(Control.CURSOR_BDIAGSIZE)
			_a_resize_corner = _a_CORNERS.BOTTOM_LEFT
		else:
			set_default_cursor_shape(Control.CURSOR_HSIZE)
			_a_resize_corner = _a_CORNERS.LEFT
		return
	
	# Top_Right, Bottom_Right, Right
	if right - p_pos.x <= 4:
		if p_pos.y - top <= 4:
			set_default_cursor_shape(Control.CURSOR_BDIAGSIZE)
			_a_resize_corner = _a_CORNERS.TOP_RIGHT
		elif bottom - p_pos.y <= 4:
			set_default_cursor_shape(Control.CURSOR_FDIAGSIZE)
			_a_resize_corner = _a_CORNERS.BOTTOM_RIGHT
		else:
			set_default_cursor_shape(Control.CURSOR_HSIZE)
			_a_resize_corner = _a_CORNERS.RIGHT
		return
	
	# Top
	if p_pos.y - top <= 4:
		set_default_cursor_shape(Control.CURSOR_VSIZE)
		_a_resize_corner = _a_CORNERS.TOP
		return
	
	# Bottom
	if bottom - p_pos.y <= 4:
		set_default_cursor_shape(Control.CURSOR_VSIZE)
		_a_resize_corner = _a_CORNERS.BOTTOM
		return
	
	_a_can_resize = false

func set_title(p_title):
	_a_Heading.set_text(p_title)
	_e_window_title = p_title

func set_resizable(p_resizable):
	if p_resizable:
		set_mouse_filter(Control.MOUSE_FILTER_PASS)
	else:
		set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	
	_e_resizable = p_resizable

func set_closeable(p_closeable):
	_e_closeable = p_closeable

func set_return_visible(p_visible):
	_a_Return.set_visible(p_visible)

func _get_new_position(p_pos):
	var pos = get_position()
	var size_ = get_size()
	var top = pos.y
	var left = pos.x
	var right = left + size_.x
	var bottom = top + size_.y

	var vp_rect = get_viewport_rect()
	var vp_top = vp_rect.position.y
	var vp_left = vp_rect.position.x
	var vp_right = vp_left + vp_rect.size.x
	var vp_bottom = vp_top + vp_rect.size.y
	var new_pos = p_pos

	if p_pos.x < vp_left:
		new_pos.x = vp_left
	elif p_pos.x + (right - left) > vp_right:
		new_pos.x = vp_right - (right - left)

	if p_pos.y < vp_top:
		new_pos.y = vp_top
	elif p_pos.y + (bottom - top) > vp_bottom:
		new_pos.y = vp_bottom - (bottom - top)

	return new_pos

func _on_gui_input(p_event):
	if _a_dragging:
		return
	
	_resize_logic(p_event)

func _on_Return_pressed():
	return_pressed.emit()

func _on_Bar_gui_input(p_event):
	if !_a_dragging && _e_resizable:
		_resize_logic(p_event)
		if _a_resizing:
			get_viewport().set_input_as_handled()
			return
	
	if Input.is_action_pressed("Mouse_Left"):
		if p_event is InputEventMouseMotion:
			var relative = p_event.get_relative()
			var pos = get_position() + relative
			var new_pos = _get_new_position(pos)
			_set_position(new_pos)
		
		_a_dragging = true
	else:
		_a_dragging = false

func _on_Close_pressed():
	if _e_closeable:
		hide()
		closed.emit()
