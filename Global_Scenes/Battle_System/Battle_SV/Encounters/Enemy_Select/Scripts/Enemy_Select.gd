extends Node

signal changed(p_instance)
signal selected(p_instance)
signal canceled()

@onready var _a_Audio_OK = get_node("Audio/OK")
@onready var _a_Audio_Cancel = get_node("Audio/Cancel")

var _a_enemies = []
var _a_enemy_keys = []
var _a_idx = 0 # Idx of selected enemy

func _ready():
	set_process_unhandled_input(false)

func _unhandled_input(p_event):
	if p_event.is_action_pressed("OK"):
		var key = _a_enemy_keys[_a_idx]
		var instance = _a_enemies[key]
		
		_a_Audio_OK.play()
		selected.emit(instance)
		close()
	
	elif p_event.is_action_pressed("Cancel"):
		_a_Audio_Cancel.play()
		canceled.emit()
		close()

func open(p_enemies):
	_a_enemies = p_enemies
	_a_enemy_keys = p_enemies.keys()
	
	select(_a_idx)
	
	set_process_unhandled_input(true)

func select(p_idx):
	_a_idx = p_idx
	
	var key = _a_enemy_keys[p_idx]
	var instance = _a_enemies[key]
	changed.emit(instance)

func close():
	set_process_unhandled_input(false)
