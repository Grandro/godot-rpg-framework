extends "res://Global_Scenes/Cutscene_System/Threads/Scripts/Thread_Base.gd"

@onready var _a_Timer = get_node("Timer")

var _a_time = 0.0

func _ready():
	super()
	_a_Timer.timeout.connect(_on_Timer_timeout)
	
	if !_a_loads_data:
		var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
		_a_time = cutscene_system_si.get_option_value(_a_args["Time"])
		_process_command()

func skip():
	super()
	
	_a_Timer.stop()
	
	_emit_completed()
	queue_free()

func _process_command():
	_a_Timer.start(_a_time)
	
	super()

func get_save_data():
	var data = super()
	var args = data["Args"]
	args["Time"] = _a_Timer.get_time_left()
	
	return data

func load_data(p_data):
	super(p_data)
	
	var args = p_data["Args"]
	_a_time = args["Time"]
	
	_process_command()

func _on_Timer_timeout():
	if !_a_skip:
		_emit_completed()
		queue_free()
