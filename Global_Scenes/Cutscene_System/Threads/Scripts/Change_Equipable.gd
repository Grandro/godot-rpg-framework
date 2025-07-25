extends "res://Global_Scenes/Cutscene_System/Threads/Scripts/Thread_Base.gd"

func _ready():
	super()
	if !_a_loads_data:
		_process_command()

func _process_command():
	var global_si = Global.get_singleton(self, "Global")
	var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
	var object_key = cutscene_system_si.get_option_value(_a_args["Object"])
	var type = cutscene_system_si.get_option_value(_a_args["Type"])
	var equipable_group = cutscene_system_si.get_option_value(_a_args["Equipable_Group"])
	_a_object = global_si.get_object(object_key)
	_a_object.comph().call_comp("Cutscene", "increase_in_cutscene")
	
	match type:
		"Equip":
			var equipable_key = cutscene_system_si.get_option_value(_a_args["Equipable"])
			_a_object.comph().call_comp("Equipment", "equip_both", [equipable_group, equipable_key])
		"Unequip":
			_a_object.comph().call_comp("Equipment", "unequip_both", [equipable_group])
	
	# Wait for equipable to be equipped
	await get_tree().process_frame
	_emit_completed()
	queue_free()
	
	super()
