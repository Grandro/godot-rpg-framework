extends "res://Global_Scenes/Cutscene_System/Threads/Scripts/Thread_Base.gd"

func _ready():
	super()
	if !_a_loads_data:
		_process_command()

func _process_command():
	var instance_key = _a_args["Instance_Key"]
	var expression = _a_args["Expression"]
	var type = _a_args["Type"]
	
	var instance = null
	match type:
		"Object":
			var global_si = Global.get_singleton(self, "Global")
			_a_object = global_si.get_object(instance_key)
			_a_object.comph().call_comp("Cutscene", "increase_in_cutscene")
			var comp = _a_args["Comp"]
			instance = _a_object.comph().get_comp(comp)
		"Singleton": 
			instance = Global.get_singleton(self, instance_key)
		"Curr_Scene": 
			instance = _a_curr_scene
	
	var expr = Expression.new()
	var error = expr.parse(expression)
	if error == OK: 
		expr.execute([], instance, true)
	else:
		print(expr.get_error_text())
	
	_emit_completed()
	queue_free()
	
	super()
