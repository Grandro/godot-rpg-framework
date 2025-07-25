extends CanvasLayer

signal command_ok(p_data, p_command)

var _a_instance = null

func open(p_instance, p_command, p_path, p_data, p_res_data):
	var scene = load(p_path)
	_a_instance = scene.instantiate()
	_a_instance.ok_pressed.connect(_on_command_ok_pressed.bind(p_command))
	_a_instance.open.call_deferred(p_instance, p_data, p_res_data)
	
	add_child(_a_instance)
	show()

func close():
	if is_instance_valid(_a_instance):
		_a_instance.close()
	hide()

func _on_command_ok_pressed(p_data, p_command):
	command_ok.emit(p_data, p_command)
