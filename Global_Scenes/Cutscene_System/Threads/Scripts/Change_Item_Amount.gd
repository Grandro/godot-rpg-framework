extends "res://Global_Scenes/Cutscene_System/Threads/Scripts/Thread_Base.gd"

func _ready():
	super()
	if !_a_loads_data:
		_process_command()

func _process_command():
	var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
	var item_key = cutscene_system_si.get_option_value(_a_args["Item"])
	if !item_key.is_empty():
		var global_si = Global.get_singleton(self, "Global")
		var type = cutscene_system_si.get_option_value(_a_args["Type"])
		var amount = cutscene_system_si.get_option_value(_a_args["Amount"])
		match type:
			"Gain": global_si.change_item_amount(item_key, amount)
			"Lose": global_si.change_item_amount(item_key, -amount)
	
	_emit_completed()
	queue_free()
	
	super()
