extends "res://Scenes/Object/Comps/3D/Movement/Scripts/Movement_Character.gd"

@onready var _a_Nav_Agent = get_node("Nav_Agent")

var _a_org_pos = Vector3.ZERO
var _a_state = ""

func init(p_entity):
	super(p_entity)
	
	_a_org_pos = p_entity.get_global_position()

func move_to_pos(p_pos):
	var pos = get_global_position()
	var path = _get_path_points(pos, p_pos)
	_a_Nav_Agent.set_path(path)

func move_to_org_pos():
	move_to_pos(_a_org_pos)

func set_state(p_state):
	_a_state = p_state

func get_state():
	return _a_state

func _get_path_points(p_start, p_end):
	var dif = p_end - p_start
	var duration = Vector3.ONE
	duration.x = max(abs(dif.x) / 2.4, 0.1)
	duration.z = max(abs(dif.z) / 2.4, 0.1)
	var dist_per_second = dif / duration
	var path = []
	if abs(dif.z) < abs(dif.x):
		var delay = duration.z / 4
		
		# dif.z in duration.z, how much in delay?
		var z_pos = delay * dist_per_second.z + p_start.z
		var point_1 = Vector3(p_start.x, 0.0, z_pos)
		
		# point_1 + Distance of both Tweens in duration.z - delay seconds
		var seconds = duration.z - delay
		var point_2 = point_1 + seconds * dist_per_second
		
		# point_2 + Distance of Tween_X in duration.x + delay - duration.z seconds
		seconds = duration.x + delay - duration.z
		var point_3 = point_2 + Vector3(seconds * dist_per_second.x, 0.0, 0.0)
		
		path = [point_2, point_3]
	else:
		var delay = duration.x / 4
		
		# dif.x in duration.x. how much in delay?
		var x_pos = delay * dist_per_second.x + p_start.x
		var point_1 = Vector3(x_pos, 0.0, p_start.z)
		
		# point_1 + Distance of both Tweens in duration.x - delay seconds
		var seconds = duration.x - delay
		var point_2 = point_1 + seconds * dist_per_second
		
		# point_2 + Distance of Tween_Z in duration.z + delay - duration.x seconds
		seconds = duration.z + delay - duration.x
		var point_3 = point_2 + Vector3(0.0, 0.0, seconds * dist_per_second.z)
		
		if point_1 == p_start:
			path = [point_2, point_3]
		else:
			path = [point_1, point_2, point_3]
	
	return path
