extends Node

signal processed()

@export var _e_keep_state : bool = false
@export var _e_use_CD : bool = true
@export var _e_CD : float = 0.1

var _a_behavior = null
var _a_entity = null
var _a_entity_comph : CompHandler = null

func init(p_behavior, p_entity, p_entity_comph):
	_a_behavior = p_behavior
	_a_entity = p_entity
	_a_entity_comph = p_entity_comph

func register(p_actions):
	p_actions[name] = self

func process_start():
	pass

func process_end():
	pass

func get_keep_state():
	return _e_keep_state

func get_use_CD():
	return _e_use_CD

func get_CD():
	return _e_CD
