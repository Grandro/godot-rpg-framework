extends Node3D

signal started()
signal finished()
signal pre_event()
signal post_event()
signal reaction_started()
signal reaction_finished()
signal hit()

var _a_entity : Character3DObject = null
var _a_actions : Node3D = null

func init(p_actions, p_entity):
	_a_actions = p_actions
	_a_entity = p_entity

func _finished():
	finished.emit()
	queue_free()
