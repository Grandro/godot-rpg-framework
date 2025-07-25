extends Node

var _a_entity = null
var _a_movement = null

func _physics_process(p_delta):
	# Handle RigidBody Collisions
	const OWN_MASS = 80.0
	for i in _a_entity.get_slide_collision_count():
		var slide_coll = _a_entity.get_slide_collision(i)
		var collider = slide_coll.get_collider()
		if _is_instance_rigid_body(collider):
			var movement_velocity = _a_movement.get_velocity()
			var collider_velocity = collider.get_linear_velocity()
			var collider_mass = collider.get_mass()
			var collider_pos = collider.get_global_position()
			var push_dir = -slide_coll.get_normal()
			var velocity_diff = movement_velocity.dot(push_dir) - collider_velocity.dot(push_dir)
			var mass_ratio = min(1.0, OWN_MASS / collider_mass)
			var slide_coll_pos = slide_coll.get_position()
			var impulse = push_dir * velocity_diff * mass_ratio * p_delta
			var pos = slide_coll_pos - collider_pos
			collider.apply_impulse(impulse, pos)

func init(p_entity):
	_a_entity = p_entity
	_a_movement = p_entity.comph().get_comp("Movement")

func reset_velocity():
	pass

func adjust_velocity_post(p_velocity):
	return p_velocity

func get_velocity_():
	return _a_movement.get_init_velocity()

func get_speed():
	return 0.0

func _is_instance_rigid_body(_p_instance):
	pass
