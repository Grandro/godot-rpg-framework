extends Node

signal processed()

var _a_states = {} # Map state to instance
var _a_instance = null # curr state instance

func init(p_behavior, p_entity, p_entity_comph):
	for child in get_children():
		child.processed.connect(_on_State_processed)
		child.init(p_behavior, p_entity, p_entity_comph)
		
		var key = child.get_name()
		_a_states[key] = child

func register(p_actions):
	p_actions[name] = self

func process_start():
	var keys = _a_states.keys()
	var rndm = randi() % keys.size()
	var key = keys[rndm]
	_a_instance = _a_states[key]
	_a_instance.process_start()

func process_end():
	_a_instance.process_end()

func get_keep_state():
	return _a_instance.get_keep_state()

func get_use_CD():
	return _a_instance.get_use_CD()

func get_CD():
	return _a_instance.get_CD()

func _on_State_processed():
	processed.emit()
