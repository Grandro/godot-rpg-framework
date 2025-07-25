extends Sprite3D

signal finished()

var _a_Shared = preload("res://Scenes/Object/Comps/Popup/Scripts/Shared.gd")

var _a_shared = null

func _ready():
	_a_shared = _a_Shared.new(self)
	_a_shared.finished.connect(_on_Shared_finished)
	
	_a_shared.ready()

func init(p_entity):
	_a_shared.init(p_entity)

func popup(p_type, p_by_command):
	_a_shared.popup(p_type, p_by_command)

func update_texture(p_type):
	_a_shared.update_texture(p_type)

func reset():
	_a_shared.reset()

func play_anim(p_name):
	_a_shared.play_anim(p_name)

func seek_anim(p_seconds, p_update = false):
	_a_shared.seek_anim(p_seconds, p_update)

func start_timer(p_seconds):
	_a_shared.start_timer(p_seconds)

func get_anim_pos():
	return _a_shared.get_anim_pos()

func get_assigned_anim():
	return _a_shared.get_assigned_anim()

func get_timer_time_left():
	return _a_shared.get_timer_time_left()

func get_save_data():
	return {}

func load_data(_p_data):
	pass

func load_data_init():
	pass

func _on_Shared_finished():
	finished.emit()
