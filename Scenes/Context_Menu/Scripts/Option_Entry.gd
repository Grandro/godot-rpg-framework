extends PanelContainer

signal select_pressed()
signal option_selected(p_option)

const _a_DISABLED_COLOR = Color(0.5, 0.5, 0.5, 1.0)
const _a_NORMAL_COLOR = Color.WHITE

var _a_Context_Menu_Scene = load("res://Scenes/Context_Menu/Context_Menu.tscn")

@onready var _a_Margin = get_node("Margin")
@onready var _a_Icon = get_node("Margin/HBox/Icon")
@onready var _a_Icon_Image = get_node("Margin/HBox/Icon/Image")
@onready var _a_Left = get_node("Margin/HBox/Left")
@onready var _a_Right = get_node("Margin/HBox/Right")
@onready var _a_Arrow = get_node("Margin/HBox/Arrow")
@onready var _a_Select = get_node("Select")
@onready var _a_Expand_Timer = get_node("Expand_Timer")

var _a_sub_menu = null # Instance of sub Context_Menu
var _a_sub_menu_layer = -1 # Layer for _a_sub_menu
var _a_option_entry_scene = null # Scene of Option_Entry for _a_sub_menu
var _a_options = {} # Options of _a_sub_menu
var _a_options_order = []
var _a_disabled = false

func _ready():
	_a_Expand_Timer.timeout.connect(_on_Expand_Timer_timeout)
	_a_Select.pressed.connect(_on_Select_pressed)
	_a_Select.mouse_entered.connect(_on_Select_mouse_entered)
	_a_Select.mouse_exited.connect(_on_Select_mouse_exited)
	
	var has_sub_menu = !_a_options.is_empty()
	_a_Arrow.set_visible(has_sub_menu)
	_a_Select.set_disabled(has_sub_menu)
	
	if has_sub_menu:
		_a_sub_menu = _a_Context_Menu_Scene.instantiate()
		_a_sub_menu.option_selected.connect(_on_Sub_Menu_option_selected)
		_a_sub_menu.set_layer(_a_sub_menu_layer)
		_a_sub_menu.set_option_entry_scene(_a_option_entry_scene)
		_a_sub_menu.set_options(_a_options)
		_a_sub_menu.set_options_order(_a_options_order)
		_a_sub_menu.set_theme.call_deferred(get_theme())
		_a_sub_menu.set_process_input.call_deferred(false)
		_a_sub_menu.hide()
		
		add_child(_a_sub_menu)

func _open_sub_menu():
	var width = get_size().x
	var pos = get_global_position()
	pos.x += width
	
	_a_sub_menu.open(pos)

func hide_icon():
	_a_Icon.hide()

func hide_left():
	_a_Left.hide()

func hide_right():
	_a_Right.hide()

func set_icon_texture(p_texture):
	_a_Icon_Image.set_texture(p_texture)

func set_left_text(p_text):
	_a_Left.set_text(p_text)

func set_right_text(p_text):
	_a_Right.set_text(p_text)

func set_sub_menu_layer(p_sub_menu_layer):
	_a_sub_menu_layer = p_sub_menu_layer

func set_option_entry_scene(p_option_entry_scene):
	_a_option_entry_scene = p_option_entry_scene

func set_options(p_options):
	_a_options = p_options

func set_options_order(p_options_order):
	_a_options_order = p_options_order

func set_disabled(p_disabled):
	if p_disabled:
		_a_Margin.set_modulate(_a_DISABLED_COLOR)
	else:
		_a_Margin.set_modulate(_a_NORMAL_COLOR)
	_a_Select.set_disabled(p_disabled)
	
	_a_disabled = p_disabled

func is_disabled():
	return _a_disabled

func has_sub_menu_rect_point(p_point):
	var has_point = false
	if is_instance_valid(_a_sub_menu):
		has_point = _a_sub_menu.has_rect_point(p_point)
	
	return has_point

func _on_Expand_Timer_timeout():
	_open_sub_menu()

func _on_Select_pressed():
	if _a_disabled:
		return
	
	if is_instance_valid(_a_sub_menu):
		_open_sub_menu()
	else:
		set_self_modulate(Color.TRANSPARENT)
		select_pressed.emit()

func _on_Select_mouse_entered():
	if _a_disabled:
		return
	
	set_self_modulate(_a_NORMAL_COLOR)
	if !is_instance_valid(_a_sub_menu):
		return
	
	if !_a_sub_menu.is_visible():
		_a_Expand_Timer.start(0.4)

func _on_Select_mouse_exited():
	if _a_disabled:
		return
	
	set_self_modulate(Color.TRANSPARENT)
	if !is_instance_valid(_a_sub_menu):
		return
	
	_a_Expand_Timer.stop()
	
	if _a_sub_menu.is_visible():
		var mouse_pos = get_local_mouse_position()
		var rect = get_rect()
		if !rect.has_point(mouse_pos):
			mouse_pos = get_viewport().get_mouse_position()
			if !_a_sub_menu.has_rect_point(mouse_pos):
				_a_sub_menu.close()

func _on_Sub_Menu_option_selected(p_option):
	option_selected.emit(p_option)
