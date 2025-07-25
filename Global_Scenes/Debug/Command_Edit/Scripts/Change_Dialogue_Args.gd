extends "res://Global_Scenes/Debug/Command_Edit/Scripts/Change_Args_Base.gd"

func _open_init(p_res_data):
	super(p_res_data)
	
	var default_value = ["Key"]
	_a_Value.set_value(default_value)
	_a_Value.expand(-1)
