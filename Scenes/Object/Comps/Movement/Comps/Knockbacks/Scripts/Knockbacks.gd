extends Node

var _a_Knockback_Scene = preload("res://Scenes/Object/Comps/Movement/Comps/Knockbacks/Knockback.tscn")

var _a_entity = null
var _a_entity_comph : CompHandler = null
var _a_movement = null
var _a_movement_comph : CompHandler = null

var _a_velocity = null # Vector

func _physics_process(_p_delta):
	_a_velocity = _a_movement.get_init_velocity()
	_process_knockbacks()

func init(p_entity):
	_a_entity = p_entity
	_a_entity_comph = p_entity.comph()
	_a_movement = _a_entity_comph.get_comp("Movement")
	_a_movement_comph = _a_movement.comph()
	
	_a_velocity = _a_movement.get_init_velocity()

func knockback(p_velocity):
	if get_child_count() == 0:
		_a_entity_comph.call_comp("States", "set_state_tmp", ["Knockback"])
		_a_entity_comph.call_comp("Anims", "update_anim")
	
	_instantiate_knockback(p_velocity)

func _instantiate_knockback(p_velocity):
	var instance = _a_Knockback_Scene.instantiate()
	instance.tree_exited.connect(_on_Knockback_tree_exited)
	instance.set_init_velocity(p_velocity)
	instance.set_wait_time(0.25)
	
	add_child(instance)

func _process_knockbacks():
	for child in get_children():
		var init_velocity = child.get_init_velocity()
		var end_velocity = _a_movement.get_init_velocity()
		var time_left = child.get_time_left()
		var duration = child.get_wait_time()
		var t = 1 - (time_left / duration)
		var velocity = init_velocity.lerp(end_velocity, t)
		_a_velocity += velocity

func reset_velocity():
	_a_velocity = _a_movement.get_init_velocity()
	for child in get_children():
		child.queue_free()

func adjust_velocity_post(p_velocity):
	return p_velocity

func get_velocity_():
	return _a_velocity

func get_speed():
	return 0.0

func _on_Knockback_tree_exited():
	if get_child_count() == 0:
		await get_tree().create_timer(0.3).timeout
		_a_entity_comph.call_comp("States", "set_state_tmp", ["Walk"])
		_a_movement.set_state("Recover_Knockback")
		_a_movement.move_to_org_pos()
		_a_entity_comph.call_comp("Anims", "update_anim")
