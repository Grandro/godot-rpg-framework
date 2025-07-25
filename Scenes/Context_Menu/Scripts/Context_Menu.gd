extends CanvasLayer

signal option_selected(p_option)

@export var _e_margin_left: int = 8
@export var _e_margin_top: int = 8
@export var _e_margin_right: int = 8
@export var _e_margin_bottom: int = 8
@export var _e_option_entry_scene: PackedScene = null
@export var _e_options: Dictionary = {} # Match key to ContextMenuOptionEntryData
@export var _e_options_order: Array[String] = []

var _a_HSep_Scene = preload("res://Scenes/Context_Menu/HSep.tscn")

const _a_OPTION_LEFT_LOC_ID = "CONTEXT_MENU_OPTIONS_%s_LEFT"
const _a_OPTION_RIGHT_LOC_ID = "CONTEXT_MENU_OPTIONS_%s_RIGHT"

@onready var _a_Content = get_node("Content")
@onready var _a_Entries = get_node("Content/Entries")

var _a_options = {} # Match option key to Option_Entry instance

func _ready():
	set_process(false)
	set_process_input(false)
	
	hide()

func _process(_p_delta):
	_a_Content.set_size(Vector2.ZERO)
	var pos = _a_Content.get_position()
	_update_content(pos)

func open(p_pos):
	_create_options()
	set_process(true)
	set_process_input(true)
	
	_a_Content.set_position(p_pos)
	
	show()

func close():
	set_process(false)
	set_process_input(false)
	_a_options.clear()
	for child in _a_Entries.get_children():
		_a_Entries.remove_child(child)
		child.queue_free()
	
	hide()

func _input(p_event):
	if p_event is InputEventMouseButton && p_event.is_pressed():
		var mouse_pos = p_event.get_position()
		if !has_rect_point(mouse_pos):
			close()

func _create_options():
	var hide_icon = true
	for option in _e_options_order:
		var args = _e_options[option]
		if args.get_icon_texture() != null:
			hide_icon = false
			break
	
	for option in _e_options_order:
		var args = _e_options[option]
		var instance = null
		var hsep = args.get_hsep()
		if hsep:
			instance = _a_HSep_Scene.instantiate()
		else:
			instance = _e_option_entry_scene.instantiate()
			instance.select_pressed.connect(_on_Option_Entry_select_pressed.bind(option))
			instance.option_selected.connect(_on_Option_Entry_option_selected)
			
			var icon_texture = args.get_icon_texture()
			instance.set_icon_texture.call_deferred(icon_texture)
			if hide_icon:
				instance.hide_icon.call_deferred()
			
			var show_left = args.get_show_left()
			if show_left:
				var left_text = tr(_a_OPTION_LEFT_LOC_ID % option.to_upper())
				instance.set_left_text.call_deferred(left_text)
			else:
				instance.hide_left.call_deferred()
			
			var show_right = args.get_show_right()
			if show_right:
				var right_text = tr(_a_OPTION_RIGHT_LOC_ID % option.to_upper())
				instance.set_right_text.call_deferred(right_text)
			else:
				instance.hide_right.call_deferred()
			
			instance.set_sub_menu_layer(get_layer())
			instance.set_option_entry_scene(_e_option_entry_scene)
			instance.set_options(args.get_options())
			instance.set_options_order(args.get_options_order())
			instance.set_disabled.call_deferred(args.get_disabled())
			instance.set_visible(args.get_visible())
			
			_a_options[option] = instance
		
		instance.set_theme(_a_Content.get_theme())
		
		_a_Entries.add_child(instance)

func _update_content(p_pos):
	var vp_size = get_viewport().get_visible_rect().size
	var size = _a_Content.get_size()
	p_pos.x = max(_e_margin_left, p_pos.x)
	p_pos.y = max(_e_margin_top, p_pos.y)
	p_pos.x = min(vp_size.x - size.x - _e_margin_right, p_pos.x)
	p_pos.y = min(vp_size.y - size.y - _e_margin_bottom, p_pos.y)
	
	_a_Content.set_position(p_pos)

func set_option_disabled(p_option, p_disabled):
	var args = _e_options[p_option]
	args.set_disabled(p_disabled)
	
	if !_a_options.is_empty():
		var instance = _a_options[p_option]
		instance.set_disabled(p_disabled)

func set_options_disabled_all(p_disabled, p_exclude = []):
	set_options_disabled(_e_options_order, p_disabled, false, p_exclude)

func set_options_disabled(p_options, p_disabled, p_flip_others, p_exclude = []):
	for option in _e_options_order:
		if p_exclude.has(option):
			continue
		
		if p_options.has(option):
			set_option_disabled(option, p_disabled)
		elif p_flip_others:
			set_option_disabled(option, !p_disabled)

func set_option_visible(p_option, p_visible):
	var args = _e_options[p_option]
	args.set_visible(p_visible)
	
	if !_a_options.is_empty():
		var instance = _a_options[p_option]
		instance.set_visible(p_visible)

func set_option_entry_scene(p_option_entry_scene):
	_e_option_entry_scene = p_option_entry_scene

func set_options(p_options):
	_e_options = p_options

func set_options_order(p_options_order):
	_e_options_order = p_options_order

func set_theme(p_theme):
	_a_Content.set_theme(p_theme)

func has_rect_point(p_point):
	var rect = _a_Content.get_rect()
	var has_point = rect.has_point(p_point)
	if has_point:
		return true
	
	for child in _a_Entries.get_children():
		if child is HSeparator:
			continue
		
		if child.has_sub_menu_rect_point(p_point):
			has_point = true
			break
	
	return has_point

func _on_Option_Entry_select_pressed(p_option):
	option_selected.emit(p_option)
	close()

func _on_Option_Entry_option_selected(p_option):
	option_selected.emit(p_option)
	close()
