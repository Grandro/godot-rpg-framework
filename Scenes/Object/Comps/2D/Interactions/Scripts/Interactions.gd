extends Node2D

signal interacted()
signal interaction_activated(p_area)
signal interaction_deactivated()

@export var _e_interaction_allowed: bool = true

var _a_Shared = preload("res://Scenes/Object/Comps/Interactions/Scripts/Shared.gd")

var _a_shared = null

func _ready():
	_a_shared = _a_Shared.new(self)
	_a_shared.interacted.connect(_on_Shared_interacted)
	_a_shared.interaction_activated.connect(_on_Shared_interaction_activated)
	_a_shared.interaction_deactivated.connect(_on_Shared_interaction_deactivated)
	_a_shared.set_interaction_allowed(_e_interaction_allowed)
	
	_a_shared.ready()

func init(p_entity):
	_a_shared.init(p_entity)

func interaction(p_area):
	_a_shared.interaction(p_area)

func interaction_activate(p_area, p_dir):
	_a_shared.interaction_activate(p_area, p_dir)

func interaction_deactivate(p_area):
	_a_shared.interaction_deactivate(p_area)

func increase_interaction_cutscene_args_idx(p_idx, p_value = 1):
	_a_shared.increase_interaction_cutscene_args_idx(p_idx, p_value)

func increase_interaction_dialogue_args_idx(p_idx, p_value = 1):
	_a_shared.increase_interaction_dialogue_args_idx(p_idx, p_value)

func set_interaction_cutscene_args_idx(p_idx, p_args_idx):
	_a_shared.set_interaction_cutscene_args_idx(p_idx, p_args_idx)

func set_interaction_dialogue_args_idx(p_idx, p_args_idx):
	_a_shared.set_interaction_dialogue_args_idx(p_idx, p_args_idx)

func set_interaction_allowed(p_interaction_allowed):
	_e_interaction_allowed = p_interaction_allowed
	_a_shared.set_interaction_allowed(p_interaction_allowed)

func get_interaction_allowed():
	return _a_shared.get_interaction_allowed()

func set_interaction_cutscene_args(p_idx, p_args):
	_a_shared.set_interaction_cutscene_args(p_idx, p_args)

func set_interaction_dialogue_args(p_idx, p_args):
	_a_shared.set_interaction_dialogue_args(p_idx, p_args)

func get_default_interaction_pos():
	return _a_shared.get_default_interaction_pos()

func get_interaction_count(p_idx):
	return _a_shared.get_interaction_count(p_idx)

func get_save_data():
	return _a_shared.get_save_data()

func load_data(p_data):
	_e_interaction_allowed = p_data["Interaction"]["Allowed"]
	_a_shared.load_data(p_data)

func load_data_init():
	pass

func _on_Shared_interacted():
	interacted.emit()

func _on_Shared_interaction_activated(p_area):
	interaction_activated.emit(p_area)

func _on_Shared_interaction_deactivated():
	interaction_deactivated.emit()
