extends Resource
class_name ObjectiveData

@export_enum("Int", "Bool", "Sub_Quest") var _e_type = "Int"
@export var _e_desc: String = "" # Loc_ID

func get_type():
	return _e_type

func get_desc():
	return _e_desc
