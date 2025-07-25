extends Resource
class_name StatsData

@export var _e_HP: int = -1
@export var _e_SP: int = -1
@export var _e_ATK: int = -1
@export var _e_MAG: int = -1
@export var _e_DEF: int = -1
@export var _e_SPEED: int = -1
@export var _e_LUCK: int = -1

func get_HP():
	return _e_HP

func get_SP():
	return _e_SP

func get_ATK():
	return _e_ATK

func get_MAG():
	return _e_MAG

func get_DEF():
	return _e_DEF

func get_SPEED():
	return _e_SPEED

func get_LUCK():
	return _e_LUCK
