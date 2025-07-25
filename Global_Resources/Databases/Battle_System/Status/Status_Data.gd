extends Resource
class_name StatusData

@export_enum("Turn_Start", "Action_Pre_Event", "Action_Post_Event")
var _e_trigger_activation : String = "Turn_Start"
@export_enum("Turn_Start", "Action_Pre_Event", "Action_Post_Event")
var _e_trigger_deactivation: String = "Turn_Start"
@export var _e_commands : Array[String] = []
@export var _e_stack : int = 99
@export var _e_init_effect : StatusEffect = null
@export var _e_trigger_effect : StatusEffect = null

func get_trigger_activation():
	return _e_trigger_activation

func get_trigger_deactivation():
	return _e_trigger_deactivation

func get_commands():
	return _e_commands

func get_stack_():
	return _e_stack

func get_init_effect():
	return _e_init_effect

func get_trigger_effect():
	return _e_trigger_effect
