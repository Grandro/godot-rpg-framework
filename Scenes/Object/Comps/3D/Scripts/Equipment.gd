extends Node3D

signal equipped(p_group, p_key)
signal unequipped(p_group)

@export var _e_scenes: Dictionary = {"Head": {}, "Torso": {}, "Legs": {},
									 "Feet": {}}
@export var _e_shaded: bool = true

var _a_Shared = preload("res://Scenes/Object/Comps/Equipment/Scripts/Shared.gd")

var _a_shared = null

func _ready():
	_a_shared = _a_Shared.new(self)
	_a_shared.equipped.connect(_on_Shared_equipped)
	_a_shared.unequipped.connect(_on_Shared_unequipped)
	_a_shared.set_scenes(_e_scenes)
	
	_a_shared.ready()

func init(p_entity):
	_a_shared.init(p_entity)

func play_anim_all(p_name, p_speed, p_backwards):
	_a_shared.play_anim_all(p_name, p_speed, p_backwards)

func seek_anim_all(p_seconds, p_update):
	_a_shared.seek_anim_all(p_seconds, p_update)

func stop_anim_all(p_keep_state):
	_a_shared.stop_anim_all(p_keep_state)

func equip_both(p_group, p_key):
	_a_shared.equip_both(p_group, p_key)

func equip(p_group, p_key):
	_a_shared.equip(p_group, p_key)

func unequip_both(p_group):
	_a_shared.unequip_both(p_group)

func unequip(p_group):
	_a_shared.unequip(p_group)

func get_scenes():
	return _a_shared.get_scenes()

func get_equipable(p_group):
	return _a_shared.get_equipable(p_group)

func get_equipables():
	return _a_shared.get_equipables()

func get_save_data():
	return _a_shared.get_save_data()

func load_data(p_data):
	_a_shared.load_data(p_data)

func load_data_init():
	_a_shared.load_data_init()

func _on_Shared_equipped(p_group, p_key):
	var instance = _a_shared.get_equipable_instance(p_group, p_key)
	instance.shaded = _e_shaded
	equipped.emit(p_group, p_key)

func _on_Shared_unequipped(p_group):
	unequipped.emit(p_group)
