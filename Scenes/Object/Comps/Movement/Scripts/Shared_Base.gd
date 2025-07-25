extends "res://Scripts/Extension_Base.gd"

var _a_reset_dir = ""

var _a_entity_entity = null
var _a_entity_entity_comph : CompHandler = null
var _a_comph = null

var _a_velocity = null # Vector
var _a_dir = "Down"
var _a_base_speed = 0.0
var _a_speed = 0.0

func _init(p_entity):
	super(p_entity)
	_a_comph = CompHandler.new(p_entity)

func ready():
	set_dir(_a_reset_dir)
	_a_velocity = _a_entity.get_init_velocity()
	_update_speed()

func init(p_entity_entity):
	_a_entity_entity = p_entity_entity
	_a_entity_entity_comph = _a_entity_entity.comph()
	
	_a_comph.register_comps(p_entity_entity)

func comph():
	return _a_comph

func stop():
	_reset_velocity()
	_a_entity_entity_comph.call_comp("States", "set_state_tmp", ["Stop"])
	_a_entity_entity_comph.call_comp("Anims", "update_anim")

func _update_speed():
	_a_speed = _a_base_speed
	for child in _a_entity.get_children():
		_a_speed += child.get_speed()

func _reset_velocity():
	_a_velocity = _a_entity.get_init_velocity()
	for child in _a_entity.get_children():
		child.reset_velocity()

func reset_dir():
	_a_dir = _a_reset_dir

func get_velocity():
	return _a_velocity

func set_dir(p_dir):
	_a_dir = p_dir

func get_dir():
	return _a_dir

func set_base_speed(p_base_speed):
	_a_base_speed = p_base_speed

func get_speed():
	return _a_speed

func set_reset_dir(p_reset_dir):
	_a_reset_dir = p_reset_dir

func get_save_data():
	var data = {}
	data["Dir"] = _a_dir
	
	return data

func load_data(p_data):
	set_dir(p_data["Dir"])
