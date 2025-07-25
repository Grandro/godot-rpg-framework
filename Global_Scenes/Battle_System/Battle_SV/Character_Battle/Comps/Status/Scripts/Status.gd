extends Node3D

const _a_TRIGGER_TYPES = ["Turn_Start", "Action_Pre_Event", "Action_Post_Event"]
const _a_STATUS_ENTRY_SCENE_PATH = "res://Global_Scenes/Battle_System/Battle_SV/Character_Battle/Comps/Status/Entries/%s.tscn"

@onready var _a_Status = get_node("Panel/VP/Status")

var _a_entity : Character3DObject = null

var _a_instances = {} # Match key to instance

func _ready():
	for child in _a_Status.get_children():
		child.queue_free()

func init(p_entity):
	_a_entity = p_entity

func handle_trigger_effects(p_trigger_type):
	_handle_trigger_effects_activation(p_trigger_type)
	_handle_trigger_effects_deactivation(p_trigger_type)

func add_status(p_key, p_amount):
	if _a_instances.has(p_key):
		var instance = _a_instances[p_key]
		instance.change_amount(p_amount)
	else:
		var data = Databases.get_data_entry("Status", p_key)
		var instance = _instantiate_status_entry(p_key, p_amount, data)
		_a_instances[p_key] = instance
		_a_Status.add_child(instance)

func remove_status():
	pass

func _handle_trigger_effects_activation(p_trigger_type):
	for key in _a_instances:
		var instance = _a_instances[key]
		var trigger_activation = instance.get_trigger_activation()
		if p_trigger_type != trigger_activation:
			continue
		
		instance.activate_trigger_effect()

func _handle_trigger_effects_deactivation(p_trigger_type):
	for key in _a_instances:
		var instance = _a_instances[key]
		var trigger_deactivation = instance.get_trigger_deactivation()
		if p_trigger_type != trigger_deactivation:
			continue
		
		instance.deactivate_trigger_effect()

func _instantiate_status_entry(p_key, p_amount, p_data):
	var trigger_activation = p_data.get_trigger_activation()
	var trigger_deactivation = p_data.get_trigger_deactivation()
	var commands = p_data.get_commands()
	var stack = p_data.get_stack_()
	var init_effect = p_data.get_init_effect()
	var trigger_effect = p_data.get_trigger_effect()
	var scene = load(_a_STATUS_ENTRY_SCENE_PATH % p_key)
	var instance = scene.instantiate()
	instance.tree_exited.connect(_on_Status_Entry_tree_exited.bind(p_key))
	instance.set_entity(_a_entity)
	instance.set_trigger_activation(trigger_activation)
	instance.set_trigger_deactivation(trigger_deactivation)
	instance.set_commands(commands)
	instance.set_stack(stack)
	instance.set_init_effect(init_effect)
	instance.set_trigger_effect(trigger_effect)
	instance.set_amount.call_deferred(p_amount)
	
	return instance

func get_save_data():
	return {}

func load_data(_p_data):
	pass

func load_data_init():
	pass

func _on_Status_Entry_tree_exited(p_key):
	_a_instances.erase(p_key)
