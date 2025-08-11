extends Node

signal changed(p_key)
signal selected(p_key, p_init)
signal canceled()

@onready var _a_Audio_OK = get_node("Audio/OK")
@onready var _a_Audio_Cancel = get_node("Audio/Cancel")

var _a_enemy_keys = []
var _a_idx = 0 # Idx of selected enemy

func _ready():
	set_process_unhandled_input(false)

func _unhandled_input(p_event):
	if p_event.is_action_pressed("OK"):
		var key = _a_enemy_keys[_a_idx]
		
		_a_Audio_OK.play()
		selected.emit(key)
		close()
	
	elif p_event.is_action_pressed("Cancel"):
		_a_Audio_Cancel.play()
		canceled.emit()
		close()
	
	elif p_event.is_action_pressed("Move_Left"):
		var idx = (_a_idx - 1) % _a_enemy_keys.size()
		select(idx)
	
	elif p_event.is_action_pressed("Move_Right"):
		var idx = (_a_idx + 1) % _a_enemy_keys.size()
		select(idx)

func open(p_enemies):
	_a_enemy_keys = p_enemies.keys()
	
	select(_a_idx, true)
	set_process_unhandled_input(true)

func select(p_idx, p_init = false):
	_a_idx = p_idx
	
	var key = _a_enemy_keys[p_idx]
	changed.emit(key, p_init)

func close():
	set_process_unhandled_input(false)
