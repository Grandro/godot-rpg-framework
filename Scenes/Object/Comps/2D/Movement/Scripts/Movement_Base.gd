extends Node2D

@export var _e_shared : GDScript = preload("res://Scenes/Object/Comps/Movement/Scripts/Shared_Base.gd")
@export_enum("Down", "Left", "Right", "Up") var _e_reset_dir = "Down"

var _a_shared = null

func _ready():
	_a_shared = _e_shared.new(self)
	_a_shared.set_reset_dir(_e_reset_dir)
	
	_a_shared.ready()

func init(p_entity):
	_a_shared.init(p_entity)

func comph():
	return _a_shared.comph()

func stop():
	_a_shared.stop()

func reset_dir():
	_a_shared.reset_dir()

func get_velocity():
	return _a_shared.get_velocity()

func set_dir(p_dir):
	_a_shared.set_dir(p_dir)

func get_dir():
	return _a_shared.get_dir()

func set_base_speed(p_base_speed):
	_a_shared.set_base_speed(p_base_speed)

func get_speed():
	return _a_shared.get_speed()

func get_init_velocity():
	return Vector2.ZERO

func get_save_data():
	return _a_shared.get_save_data()

func load_data(p_data):
	_a_shared.load_data(p_data)

func load_data_init():
	pass
