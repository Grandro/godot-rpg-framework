extends Camera3D

signal made_current()

var _a_limit = {} # Match margin to limit

var _a_base_offset = Vector2.ZERO
var _a_offset = [0, 0, 0, 0] # SIDE enum to offset

func _ready():
	_a_limit[SIDE_LEFT] = -10000000
	_a_limit[SIDE_TOP] = -10000000
	_a_limit[SIDE_RIGHT] = 10000000
	_a_limit[SIDE_BOTTOM] = 10000000
	
	_a_base_offset = get_position()

func _process(_p_delta):
	if !current:
		return
	
	var top_left = Vector2.ZERO
	var bottom_right =  Global.get_base_vp_size()
	var screen_pos = [top_left, bottom_right]
	var world_pos = []
	for curr_screen_pos in screen_pos:
		var origin = project_ray_origin(curr_screen_pos)
		var dir = project_ray_normal(curr_screen_pos)
		var distance = -origin.y / dir.y
		var curr_world_pos = origin + dir * distance
		world_pos.push_back(curr_world_pos)
	
	# Top
	var top_dif = _a_limit[SIDE_TOP] - (world_pos[0].z - _a_offset[SIDE_TOP])
	_a_offset[SIDE_TOP] = max(0.0, top_dif)
	if _a_offset[SIDE_TOP] > 0.0:
		position.z = _a_base_offset.z + _a_offset[SIDE_TOP]
	
	# Left
	var left_dif = _a_limit[SIDE_LEFT] - (world_pos[0].x - _a_offset[SIDE_LEFT])
	_a_offset[SIDE_LEFT] = max(0.0, left_dif)
	if _a_offset[SIDE_LEFT] > 0.0:
		position.x = _a_base_offset.x + _a_offset[SIDE_LEFT]
	
	# Right
	var right_dif = _a_limit[SIDE_RIGHT] - (world_pos[1].x - _a_offset[SIDE_RIGHT])
	_a_offset[SIDE_RIGHT] = min(0.0, right_dif)
	if _a_offset[SIDE_RIGHT] < 0.0:
		position.x = _a_base_offset.x + _a_offset[SIDE_RIGHT]
	
	# Down
	var down_dif = _a_limit[SIDE_BOTTOM] - (world_pos[1].z - _a_offset[SIDE_BOTTOM])
	_a_offset[SIDE_BOTTOM] = min(0.0, down_dif)
	if _a_offset[SIDE_BOTTOM] < 0.0:
		position.z = _a_base_offset.z + _a_offset[SIDE_BOTTOM]
	
	# No limit => default pos
	if _a_offset[SIDE_LEFT] == 0.0 && _a_offset[SIDE_RIGHT] == 0.0:
		position.x = _a_base_offset.x
	if _a_offset[SIDE_TOP] == 0.0 && _a_offset[SIDE_BOTTOM] == 0.0:
		position.z = _a_base_offset.z

func init(_p_entity):
	pass

func make_current_():
	make_current()
	made_current.emit()

func set_limit(p_margin, p_limit):
	_a_limit[p_margin] = p_limit

func get_limit(p_margin):
	return _a_limit[p_margin]

func get_save_data():
	var data = {}
	data["Curr"] = is_current()
	data["Size"] = get_size()
	
	return data

func load_data(p_data):
	if p_data["Curr"]:
		var global_si = Global.get_singleton(self, "Global")
		global_si.set_curr_camera(self)
	set_size(p_data["Size"])

func load_data_init():
	pass
