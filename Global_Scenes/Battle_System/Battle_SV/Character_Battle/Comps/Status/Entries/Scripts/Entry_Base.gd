extends MarginContainer

@onready var _a_Amount = get_node("Amount")

var _a_entity : Character3DObject = null

var _a_trigger_activation = ""
var _a_trigger_deactivation = ""
var _a_commands = []
var _a_stack = -1
var _a_amount = -1
var _a_init_effect : StatusEffect = null
var _a_trigger_effect : StatusEffect = null

func _ready():
	_activate_init_effect()

func activate_trigger_effect():
	if _a_trigger_effect == null:
		return
	
	_a_trigger_effect.activate(_a_entity)

func deactivate_trigger_effect():
	if _a_trigger_effect == null:
		return
	
	_a_trigger_effect.deactivate(_a_entity)
	
	change_amount(-1)

func change_amount(p_amount):
	set_amount(_a_amount + p_amount)

func _activate_init_effect():
	if _a_init_effect != null:
		_a_init_effect.activate(_a_entity)

func set_entity(p_entity):
	_a_entity = p_entity

func set_trigger_activation(p_trigger_activation):
	_a_trigger_activation = p_trigger_activation

func get_trigger_activation():
	return _a_trigger_activation

func set_trigger_deactivation(p_trigger_deactivation):
	_a_trigger_deactivation = p_trigger_deactivation

func get_trigger_deactivation():
	return _a_trigger_deactivation

func set_commands(p_commands):
	_a_commands = p_commands

func set_stack(p_stack):
	_a_stack = p_stack

func set_amount(p_amount):
	_a_amount = min(_a_stack, p_amount)
	_a_Amount.set_text(str(_a_amount))
	
	if p_amount == 0:
		queue_free()

func set_init_effect(p_init_effect):
	_a_init_effect = p_init_effect

func set_trigger_effect(p_trigger_effect):
	_a_trigger_effect = p_trigger_effect
