extends Node2D

signal choice_selected(p_value)

@export var _e_text_box_margin_screen: Vector2 = Vector2(8, 8)
@export var _e_arrow_margin_screen: Vector2 = Vector2(24, 24)

@onready var _a_Speech_Bubble_UI = get_node("Speech_Bubble_UI")

var _a_text_box_pos_tl = Vector2.ZERO
var _a_text_box_pos_br = Vector2.ZERO
var _a_arrow_pos_tl = Vector2.ZERO
var _a_arrow_pos_br = Vector2.ZERO
var _a_inside_canvas = false

func _ready():
	_a_Speech_Bubble_UI.choice_selected.connect(_on_Speech_Bubble_UI_choice_selected)
	
	_a_inside_canvas = get_canvas_layer_node() != null
	
	set_process(false)

func _process(_p_delta):
	_start()
	if !_a_inside_canvas:
		_2D_to_screen()
	_adjust_on_screen()
	if !_a_inside_canvas:
		_screen_to_2D()
	
	_a_Speech_Bubble_UI.set_global_position(_a_text_box_pos_tl)
	_a_Speech_Bubble_UI.set_arrow_global_pos(_a_arrow_pos_tl)

func init(p_entity):
	var entity_comph = p_entity.comph()
	if entity_comph.has_comp("Interactions"):
		var interactions_comp = entity_comph.get_comp("Interactions")
		interactions_comp.interaction_activated.connect(_on_Interactions_interaction_activated)

func open(p_ensure_visibility):
	if p_ensure_visibility:
		set_process(true)
	_a_Speech_Bubble_UI.open()
	show()

func _close(p_fade_out):
	set_process(false)
	if p_fade_out:
		hide()

func reset(p_fade_out):
	_a_Speech_Bubble_UI.reset(p_fade_out)
	_close(p_fade_out)

func show_proceed_dot():
	_a_Speech_Bubble_UI.show_proceed_dot()

func open_choices_box(p_args):
	_a_Speech_Bubble_UI.open_choices_box(p_args)

func _start():
	var text_box_size_px = _a_Speech_Bubble_UI.get_size()
	var text_box_pos_br_px = Vector2(-132, -116) + Vector2(264, 96)
	var text_box_pos_tl_px = text_box_pos_br_px - text_box_size_px
	_a_text_box_pos_tl = to_global(text_box_pos_tl_px)
	_a_text_box_pos_br = to_global(text_box_pos_br_px)
	
	var arrow_size_px = _a_Speech_Bubble_UI.get_arrow_size() - Vector2(0.0, 3.0)
	var arrow_pos_tl_px = text_box_pos_tl_px
	arrow_pos_tl_px.x += text_box_size_px.x / 2.0 - arrow_size_px.x / 2.0
	arrow_pos_tl_px.y += text_box_size_px.y - 3.0
	var arrow_pos_br_px = arrow_pos_tl_px + arrow_size_px
	_a_arrow_pos_tl = to_global(arrow_pos_tl_px)
	_a_arrow_pos_br = to_global(arrow_pos_br_px)

func _2D_to_screen():
	var canvas_transform = get_viewport().get_canvas_transform()
	
	# Text_Box
	_a_text_box_pos_tl = canvas_transform * _a_text_box_pos_tl
	_a_text_box_pos_br = canvas_transform * _a_text_box_pos_br
	
	# Arrow
	_a_arrow_pos_tl = canvas_transform * _a_arrow_pos_tl
	_a_arrow_pos_br = canvas_transform * _a_arrow_pos_br

func _adjust_on_screen():
	var window_size = get_viewport().get_size()
	var text_box_size_screen = _a_text_box_pos_br - _a_text_box_pos_tl
	var arrow_size_screen = _a_arrow_pos_br - _a_arrow_pos_tl
	var arrow_flip_v = false
	
	# Left_Out
	# Text_Box
	if _a_text_box_pos_tl.x < _e_text_box_margin_screen.x:
		var diff = _e_text_box_margin_screen.x - _a_text_box_pos_tl.x
		_a_text_box_pos_tl.x += diff
	
	# Arrow
	if _a_arrow_pos_tl.x < _e_arrow_margin_screen.x:
		_a_arrow_pos_tl.x = _e_arrow_margin_screen.x
	
	# Right Out
	# Text_Box
	if _a_text_box_pos_tl.x + text_box_size_screen.x > window_size.x - _e_text_box_margin_screen.x:
		var diff = _a_text_box_pos_tl.x + text_box_size_screen.x - window_size.x + _e_text_box_margin_screen.x
		_a_text_box_pos_tl.x -= diff
	
	# Arrow
	if _a_arrow_pos_tl.x + arrow_size_screen.x > window_size.x - _e_arrow_margin_screen.x:
		_a_arrow_pos_tl.x = window_size.x - arrow_size_screen.x - _e_arrow_margin_screen.x
	
	# Up Out
	# Text_Box
	if _a_text_box_pos_tl.y < _e_text_box_margin_screen.y:
		var diff = _e_text_box_margin_screen.y - _a_text_box_pos_tl.y
		_a_text_box_pos_tl.y += diff + arrow_size_screen.y
		_a_arrow_pos_tl.y = _e_text_box_margin_screen.y
		arrow_flip_v = true
	
	# Down Out
	# Arrow
	if _a_arrow_pos_tl.y + arrow_size_screen.y > window_size.y - _e_text_box_margin_screen.y:
		var diff = _a_arrow_pos_tl.y + arrow_size_screen.y - window_size.y + _e_text_box_margin_screen.y
		_a_text_box_pos_tl.y -= diff
		_a_arrow_pos_tl.y -= diff
	
	_a_Speech_Bubble_UI.set_arrow_flip_v(arrow_flip_v)

func _screen_to_2D():
	var canvas_transform = get_viewport().get_canvas_transform()
	_a_text_box_pos_tl = canvas_transform.affine_inverse() * _a_text_box_pos_tl
	_a_arrow_pos_tl = canvas_transform.affine_inverse() * _a_arrow_pos_tl

func set_text(p_text):
	_a_Speech_Bubble_UI.set_text(p_text)

func set_text_visible_characters(p_amount):
	_a_Speech_Bubble_UI.set_text_visible_characters(p_amount)

func get_text_visible_characters():
	return _a_Speech_Bubble_UI.get_text_visible_characters()

func get_text_length():
	return _a_Speech_Bubble_UI.get_text_length()

func get_save_data():
	return {}

func load_data(_p_data):
	pass

func load_data_init():
	pass

func _on_Interactions_interaction_activated(p_area):
	var speech_bubble_pos = p_area.get_speech_bubble_pos()
	set_position(speech_bubble_pos)

func _on_Speech_Bubble_UI_choice_selected(p_value):
	choice_selected.emit(p_value)
