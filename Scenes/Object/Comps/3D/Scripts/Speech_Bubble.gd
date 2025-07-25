extends Node3D

signal choice_selected(p_value)

@export var _e_margin: Vector2 = Vector2(8, 8)

@onready var _a_Panel = get_node("Panel")
@onready var _a_Plane = get_node("Panel/Plane")
@onready var _a_VP = get_node("Panel/VP")
@onready var _a_Speech_Bubble_UI = get_node("Panel/VP/Speech_Bubble_UI")

var _a_pos_px = _Positions.new()
var _a_pos_m_old = _Positions.new()
var _a_pos_vp = _Positions.new()
var _a_pos_m_new = _Positions.new()
var _a_panel_offset = Vector3.ZERO
var _a_arrow_flip_v = false

func _ready():
	_a_Speech_Bubble_UI.choice_selected.connect(_on_Speech_Bubble_UI_choice_selected)
	
	set_process(false)

func _process(_p_delta):
	var global_si = Global.get_singleton(self, "Global")
	var curr_camera = global_si.get_curr_camera()
	var vp_size = global_si.get_base_vp_size()
	var panel_vp_size = _a_VP.get_size_2d_override()
	var plane_mesh = _a_Plane.get_mesh()
	var plane_mesh_size = plane_mesh.get_size()
	var px_per_m = Vector2(panel_vp_size) / plane_mesh_size
	
	#look_at(curr_camera.global_position, Vector3.UP, true)
	
	_2D_to_3D_text_box(plane_mesh_size, px_per_m)
	_3D_to_vp_text_box(curr_camera)
	_vp_adjust_text_box(vp_size)
	if !_vp_to_3D_text_box(curr_camera):
		return
	_2D_to_3D_arrow(plane_mesh_size, px_per_m)
	_3D_to_vp(curr_camera)
	_vp_adjust_arrow(vp_size)
	if !_vp_to_3D_arrow(curr_camera):
		return
	_3D_to_2D(plane_mesh_size, px_per_m)

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

func _2D_to_3D_text_box(p_plane_mesh_size, p_px_per_m):
	# Text_Box
	var text_box_size_px = _a_Speech_Bubble_UI.get_size()
	# 2D
	_a_pos_px.text_box[CORNER_BOTTOM_RIGHT] = Vector2(18, 180) + Vector2(264, 96)
	_a_pos_px.text_box[CORNER_TOP_LEFT] = _a_pos_px.text_box[CORNER_BOTTOM_RIGHT]
	_a_pos_px.text_box[CORNER_TOP_LEFT] -= text_box_size_px
	_a_pos_px.text_box[CORNER_TOP_RIGHT] = _a_pos_px.text_box[CORNER_BOTTOM_RIGHT]
	_a_pos_px.text_box[CORNER_TOP_RIGHT].y -= text_box_size_px.y
	_a_pos_px.text_box[CORNER_BOTTOM_LEFT] = _a_pos_px.text_box[CORNER_BOTTOM_RIGHT]
	_a_pos_px.text_box[CORNER_BOTTOM_LEFT].x -= text_box_size_px.x
	for i in 4:
		# Local 3D
		_a_pos_m_old.text_box[i] = _px_to_m(_a_pos_px.text_box[i], p_plane_mesh_size, p_px_per_m)
		# Global 3D
		_a_pos_m_old.text_box[i] = to_global(_a_pos_m_old.text_box[i])

func _3D_to_vp_text_box(p_curr_camera):
	for i in 4:
		_a_pos_vp.text_box[i] = p_curr_camera.unproject_position(_a_pos_m_old.text_box[i])

func _vp_adjust_text_box(p_vp_size):
	# Left
	if _a_pos_vp.text_box[CORNER_TOP_LEFT].x < _a_pos_vp.text_box[CORNER_BOTTOM_LEFT].x:
		_a_pos_vp.text_box[CORNER_TOP_LEFT] = _vp_adjust_left_pos(_a_pos_vp.text_box[CORNER_TOP_LEFT], 0.0, _e_margin)
	else:
		_a_pos_vp.text_box[CORNER_BOTTOM_LEFT] = _vp_adjust_left_pos(_a_pos_vp.text_box[CORNER_BOTTOM_LEFT], 0.0, _e_margin)
	
	# Right
	if _a_pos_vp.text_box[CORNER_TOP_RIGHT].x > _a_pos_vp.text_box[CORNER_BOTTOM_RIGHT].x:
		_a_pos_vp.text_box[CORNER_TOP_RIGHT] = _vp_adjust_right_pos(_a_pos_vp.text_box[CORNER_TOP_RIGHT], p_vp_size.x, _e_margin)
	else:
		_a_pos_vp.text_box[CORNER_BOTTOM_RIGHT] = _vp_adjust_right_pos(_a_pos_vp.text_box[CORNER_BOTTOM_RIGHT], p_vp_size.x, _e_margin)
	
	# Top
	if _a_pos_vp.text_box[CORNER_TOP_LEFT].y < _a_pos_vp.text_box[CORNER_TOP_RIGHT].y:
		_a_pos_vp.text_box[CORNER_TOP_LEFT] = _vp_adjust_top_pos(_a_pos_vp.text_box[CORNER_TOP_LEFT], 0.0, _e_margin)
	else:
		_a_pos_vp.text_box[CORNER_TOP_RIGHT] = _vp_adjust_top_pos(_a_pos_vp.text_box[CORNER_TOP_RIGHT], 0.0, _e_margin)
	
	# Bottom
	if _a_pos_vp.text_box[CORNER_BOTTOM_LEFT].y > _a_pos_vp.text_box[CORNER_BOTTOM_RIGHT].y:
		_a_pos_vp.text_box[CORNER_BOTTOM_LEFT] = _vp_adjust_bottom_pos(_a_pos_vp.text_box[CORNER_BOTTOM_LEFT], p_vp_size.y, _e_margin)
	else:
		_a_pos_vp.text_box[CORNER_BOTTOM_RIGHT] = _vp_adjust_bottom_pos(_a_pos_vp.text_box[CORNER_BOTTOM_RIGHT], p_vp_size.y, _e_margin)

func _vp_to_3D_text_box(p_curr_camera):
	var normal = global_transform.basis.z.normalized()
	var origin = global_transform.origin
	var plane = Plane(normal, origin)
	
	_a_panel_offset = Vector3.ZERO
	for i in 4:
		var ray_from = p_curr_camera.project_ray_origin(_a_pos_vp.text_box[i])
		var ray_to = ray_from + p_curr_camera.project_ray_normal(_a_pos_vp.text_box[i])
		_a_pos_m_new.text_box[i] = plane.intersects_ray(ray_from, ray_from.direction_to(ray_to))
		if _a_pos_m_new.text_box[i] == null:
			return false
		
		_a_panel_offset += _a_pos_m_new.text_box[i] - _a_pos_m_old.text_box[i]
	
	return true

func _2D_to_3D_arrow(p_plane_mesh_size, p_px_per_m):
	# Arrow
	_a_arrow_flip_v = false
	if !is_equal_approx(_a_pos_m_new.text_box[CORNER_TOP_LEFT].y, _a_pos_m_old.text_box[CORNER_TOP_LEFT].y):
		_a_arrow_flip_v = true
	elif !is_equal_approx(_a_pos_m_new.text_box[CORNER_TOP_RIGHT].y, _a_pos_m_old.text_box[CORNER_TOP_RIGHT].y):
		_a_arrow_flip_v = true
	_a_Speech_Bubble_UI.set_arrow_flip_v(_a_arrow_flip_v)
	
	# 2D
	var text_box_size_px = _a_Speech_Bubble_UI.get_size()
	var arrow_size_px = _a_Speech_Bubble_UI.get_arrow_size() - Vector2(0.0, 3.0)
	_a_pos_px.arrow[CORNER_TOP_LEFT] = _a_pos_px.text_box[CORNER_TOP_LEFT]
	_a_pos_px.arrow[CORNER_TOP_LEFT].x += text_box_size_px.x / 2.0 - arrow_size_px.x / 2.0
	if _a_arrow_flip_v:
		_a_pos_px.arrow[CORNER_TOP_LEFT].y -= arrow_size_px.y
	else:
		_a_pos_px.arrow[CORNER_TOP_LEFT].y += text_box_size_px.y - 3.0
	_a_pos_px.arrow[CORNER_TOP_RIGHT] = _a_pos_px.arrow[CORNER_TOP_LEFT]
	_a_pos_px.arrow[CORNER_TOP_RIGHT].x += arrow_size_px.x
	_a_pos_px.arrow[CORNER_BOTTOM_LEFT] = _a_pos_px.arrow[CORNER_TOP_LEFT]
	_a_pos_px.arrow[CORNER_BOTTOM_LEFT].y += arrow_size_px.y
	_a_pos_px.arrow[CORNER_BOTTOM_RIGHT] = _a_pos_px.arrow[CORNER_TOP_LEFT]
	_a_pos_px.arrow[CORNER_BOTTOM_RIGHT] += arrow_size_px
	for i in 4:
		# Local 3D
		_a_pos_m_old.arrow[i] = _px_to_m(_a_pos_px.arrow[i], p_plane_mesh_size, p_px_per_m)
		# Global 3D
		_a_pos_m_old.arrow[i] = to_global(_a_pos_m_old.arrow[i])
		
		_a_pos_m_old.arrow[i].y += _a_panel_offset.y
		_a_pos_m_old.text_box[i] += _a_panel_offset

func _3D_to_vp(p_curr_camera):
	for i in 4:
		_a_pos_vp.text_box[i] = p_curr_camera.unproject_position(_a_pos_m_old.text_box[i])
		_a_pos_vp.arrow[i] = p_curr_camera.unproject_position(_a_pos_m_old.arrow[i])

func _vp_adjust_arrow(p_vp_size):
	# Left
	var left_border = 0.0
	if _a_arrow_flip_v:
		left_border = _a_pos_vp.text_box[CORNER_TOP_LEFT].x
	else:
		left_border = _a_pos_vp.text_box[CORNER_BOTTOM_LEFT].x
	if _a_pos_vp.arrow[CORNER_TOP_LEFT].x < _a_pos_vp.arrow[CORNER_BOTTOM_LEFT].x:
		_a_pos_vp.arrow[CORNER_TOP_LEFT] = _vp_adjust_left_pos(_a_pos_vp.arrow[CORNER_TOP_LEFT], left_border, _e_margin)
	else:
		_a_pos_vp.arrow[CORNER_BOTTOM_LEFT] = _vp_adjust_left_pos(_a_pos_vp.arrow[CORNER_BOTTOM_LEFT], left_border, _e_margin)
	
	# Right
	var right_border = 0.0
	if _a_arrow_flip_v:
		right_border = _a_pos_vp.text_box[CORNER_TOP_RIGHT].x
	else:
		right_border = _a_pos_vp.text_box[CORNER_BOTTOM_RIGHT].x
	if _a_pos_vp.arrow[CORNER_TOP_RIGHT].x > _a_pos_vp.arrow[CORNER_BOTTOM_RIGHT].x:
		_a_pos_vp.arrow[CORNER_TOP_RIGHT] = _vp_adjust_right_pos(_a_pos_vp.arrow[CORNER_TOP_RIGHT], right_border, _e_margin)
	else:
		_a_pos_vp.arrow[CORNER_BOTTOM_RIGHT] = _vp_adjust_right_pos(_a_pos_vp.arrow[CORNER_BOTTOM_RIGHT], right_border, _e_margin)
	
	# Top
	if _a_pos_vp.arrow[CORNER_TOP_LEFT].y < _a_pos_vp.arrow[CORNER_TOP_RIGHT].y:
		_a_pos_vp.arrow[CORNER_TOP_LEFT] = _vp_adjust_top_pos(_a_pos_vp.arrow[CORNER_TOP_LEFT], 0.0, _e_margin)
	else:
		_a_pos_vp.arrow[CORNER_TOP_RIGHT] = _vp_adjust_top_pos(_a_pos_vp.arrow[CORNER_TOP_RIGHT], 0.0, _e_margin)
	
	# Bottom
	if _a_pos_vp.arrow[CORNER_BOTTOM_LEFT].y > _a_pos_vp.arrow[CORNER_BOTTOM_RIGHT].y:
		_a_pos_vp.arrow[CORNER_BOTTOM_LEFT] = _vp_adjust_bottom_pos(_a_pos_vp.arrow[CORNER_BOTTOM_LEFT], p_vp_size.y, _e_margin)
	else:
		_a_pos_vp.arrow[CORNER_BOTTOM_RIGHT] = _vp_adjust_bottom_pos(_a_pos_vp.arrow[CORNER_BOTTOM_RIGHT], p_vp_size.y, _e_margin)

func _vp_to_3D_arrow(p_curr_camera):
	var normal = global_transform.basis.z.normalized()
	var origin = global_transform.origin
	var plane = Plane(normal, origin)
	
	var offset = Vector3.ZERO
	for i in 4:
		var ray_from = p_curr_camera.project_ray_origin(_a_pos_vp.arrow[i])
		var ray_to = ray_from + p_curr_camera.project_ray_normal(_a_pos_vp.arrow[i])
		_a_pos_m_new.arrow[i] = plane.intersects_ray(ray_from, ray_from.direction_to(ray_to))
		if _a_pos_m_new.arrow[i] == null:
			return false
		
		offset += _a_pos_m_new.arrow[i] - _a_pos_m_old.arrow[i]
	
	_a_Panel.position = _a_panel_offset
	_a_Panel.position.y += offset.y
	
	_a_pos_m_old.arrow[CORNER_TOP_LEFT] -= _a_panel_offset
	_a_pos_m_old.arrow[CORNER_TOP_LEFT].x += offset.x
	_a_pos_m_new.arrow[CORNER_TOP_LEFT] = to_local(_a_pos_m_old.arrow[CORNER_TOP_LEFT])
	
	return true

func _3D_to_2D(p_plane_mesh_size, p_px_per_m):
	var arrow_pos_tl = _m_to_pixel(_a_pos_m_new.arrow[CORNER_TOP_LEFT], p_plane_mesh_size, p_px_per_m)
	_a_Speech_Bubble_UI.set_arrow_global_pos(arrow_pos_tl)

func _vp_adjust_left_pos(p_pos, p_border, p_margin):
	if p_pos.x < p_border + p_margin.x:
		var diff = p_border + p_margin.x - p_pos.x
		p_pos.x += diff
	
	return p_pos

func _vp_adjust_right_pos(p_pos, p_border, p_margin):
	if p_pos.x > p_border - p_margin.x:
		var diff = p_pos.x - p_border + p_margin.x
		p_pos.x -= diff
	
	return p_pos

func _vp_adjust_top_pos(p_pos, p_border, p_margin):
	if p_pos.y < p_border + p_margin.y:
		var diff = p_border + p_margin.y - p_pos.y
		p_pos.y += diff
	
	return p_pos

func _vp_adjust_bottom_pos(p_pos, p_border, p_margin):
	if p_pos.y > p_border - p_margin.y:
		var diff = p_pos.y - p_border + p_margin.y
		p_pos.y -= diff
	
	return p_pos

func _px_to_m(p_pos_px, p_plane_mesh_size, p_px_per_m):
	var pos_m = Vector3.ZERO
	pos_m.x -= p_plane_mesh_size.x / 2.0
	pos_m.y += p_plane_mesh_size.y / 2.0
	pos_m.x += p_pos_px.x / p_px_per_m.x
	pos_m.y -= p_pos_px.y / p_px_per_m.y
	
	return pos_m

func _m_to_pixel(p_pos_m, p_plane_mesh_size, p_px_per_m):
	var pos_px = Vector2.ZERO
	pos_px.x += p_plane_mesh_size.x * p_px_per_m.x / 2.0
	pos_px.y += p_plane_mesh_size.y * p_px_per_m.y / 2.0
	pos_px.x += p_pos_m.x * p_px_per_m.x
	pos_px.y -= p_pos_m.y * p_px_per_m.y
	
	return pos_px

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

class _Positions:
	var text_box : Array
	var arrow : Array
	
	func _init():
		text_box.resize(4)
		arrow.resize(4)
		for i in 4:
			text_box[i] = null
			arrow[i] = null
