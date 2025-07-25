extends Timer

var _a_init_velocity = null # Vector

func _ready():
	timeout.connect(_on_timeout)

func set_init_velocity(p_init_velocity):
	_a_init_velocity = p_init_velocity

func get_init_velocity():
	return _a_init_velocity

func _on_timeout():
	queue_free()
