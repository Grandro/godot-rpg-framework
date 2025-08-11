extends Node3D

signal started()
signal finished()
signal pre_event()
signal post_event()
signal reaction_started()
signal reaction_finished()
signal hit()

var _a_entity = null
var _a_args = {}

func init(p_entity):
	_a_entity = p_entity

func process(p_scene):
	var instance = _instantiate_action(p_scene)
	add_child(instance)
	
	instance.process()

func update_args(p_args, p_data):
	for key in p_args:
		_a_args[key] = p_data[key]

func _instantiate_action(p_scene):
	var instance = p_scene.instantiate()
	instance.started.connect(_on_Action_started)
	instance.finished.connect(_on_Action_finished)
	instance.pre_event.connect(_on_Action_pre_event)
	instance.post_event.connect(_on_Action_post_event)
	instance.reaction_started.connect(_on_Action_reaction_started)
	instance.reaction_finished.connect(_on_Action_reaction_finished)
	instance.hit.connect(_on_Action_hit)
	instance.init(self, _a_entity)
	
	return instance

func get_arg(p_action):
	return _a_args[p_action]

func get_args():
	return _a_args

func _on_Action_started():
	started.emit()

func _on_Action_finished():
	finished.emit()

func _on_Action_pre_event():
	pre_event.emit()

func _on_Action_post_event():
	post_event.emit()

func _on_Action_reaction_started():
	reaction_started.emit()

func _on_Action_reaction_finished():
	reaction_finished.emit()

func _on_Action_hit():
	hit.emit()
