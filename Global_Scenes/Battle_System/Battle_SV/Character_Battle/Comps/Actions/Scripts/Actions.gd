extends Node3D

signal started()
signal finished()
signal pre_event()
signal post_event()
signal reaction_started()
signal reaction_finished()
signal hit()

@export var _e_commands : Dictionary[String, PackedScene] = {}
@export var _e_specials : Dictionary[String, PackedScene] = {}

@onready var _a_Commands = get_node("Commands")
@onready var _a_Specials = get_node("Specials")

func init(p_entity):
	for child in get_children():
		child.started.connect(_on_Action_started)
		child.finished.connect(_on_Action_finished)
		child.pre_event.connect(_on_Action_pre_event)
		child.post_event.connect(_on_Action_post_event)
		child.reaction_started.connect(_on_Action_reaction_started)
		child.reaction_finished.connect(_on_Action_reaction_finished)
		child.hit.connect(_on_Action_hit)
		child.init(p_entity)

func process_command(p_command):
	var scene = _e_commands[p_command]
	_a_Commands.process(scene)

func process_special(p_special):
	var scene = _e_specials[p_special]
	_a_Specials.process(scene)

func update_data(p_data):
	var actions_data = Databases.get_data("SV_Actions")
	_a_Commands.update_args(p_data["Commands"], actions_data["Commands"])
	_a_Specials.update_args(p_data["Specials"], actions_data["Specials"])

func get_commands_arg(p_command):
	return _a_Commands.get_arg(p_command)

func get_specials_args():
	return _a_Specials.get_args()

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
